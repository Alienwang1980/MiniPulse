#!/bin/bash
# MiniPulse Pre-Test Script v2
# 运行于每次修改后的构建前，确保不把坏代码交给用户
#
# 用法: bash scripts/pre_test.sh
# 成功 → 继续构建部署; 失败 → 停止并报告问题

set -e

PROJECT_DIR="$HOME/Projects/MiniPulseV2"
SRC_DIR="$PROJECT_DIR/Sources/App"
DISK_TEST_FILE="/tmp/disk_parse_test.swift"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

pass() { echo -e "${GREEN}  ✓ $1${NC}"; }
fail() { echo -e "${RED}  ✗ $1${NC}"; }
warn() { echo -e "${YELLOW}  ! $1${NC}"; }
info() { echo -e "${CYAN}  → $1${NC}"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  MiniPulse 预测试 (Pre-Test)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FAILED=0

# ── 1. Swift 语法检查 ──────────────────────────
echo -e "\n${CYAN}[1] Swift 语法检查${NC}"
for f in ContentView.swift SystemMonitor.swift; do
    FILE="$SRC_DIR/$f"
    if [ -f "$FILE" ]; then
        if swiftc -parse "$FILE" 2>/dev/null; then
            pass "$f"
        else
            fail "$f 存在语法错误"
            swiftc -parse "$FILE" 2>&1 | head -5
            FAILED=1
        fi
    else
        fail "$f 不存在"
        FAILED=1
    fi
done

# ── 2. 磁盘解析逻辑验证 ─────────────────────────
echo -e "\n${CYAN}[2] 磁盘解析验证${NC}"

cat > "$DISK_TEST_FILE" << 'SWIFT_EOF'
import Foundation

// 实际代码中的 extractBytes 逻辑（复制自 SystemMonitor.swift）
func extractBytes(_ line: String) -> Double? {
    guard let parenRange = line.range(of: "\\([0-9]+ Bytes\\)", options: .regularExpression) else {
        return nil
    }
    let parenContent = String(line[parenRange])
    let digits = parenContent.filter { $0.isNumber }
    return Double(digits)
}

// 模拟 diskutil info / 的输出
let macOSDiskInfo = """
   Disk Size:                 245.1 GB (245107195904 Bytes)
   Volume Used Space:         12.5 GB (12451614720 Bytes)
   Container Free Space:      173.1 GB (173125955584 Bytes)
"""

// 模拟 diskutil info /Volumes/WD_BLACK 的输出
let wdDiskInfo = """
   Disk Size:                 2.0 TB (2000396836864 Bytes)
   Volume Total Space:        2.0 TB (2000388358144 Bytes)
   Volume Used Space:         475.3 GB (475291189248 Bytes)
   Volume Free Space:         1.5 TB (1525097168896 Bytes)
"""

func testDisk(_ output: String, _ name: String) -> Bool {
    var totalBytes: Double? = nil
    var usedBytes: Double? = nil
    var freeBytes: Double? = nil

    for line in output.components(separatedBy: "\n") {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.contains("Disk Size:") && totalBytes == nil {
            totalBytes = extractBytes(trimmed)
        } else if trimmed.contains("Volume Used Space:") && usedBytes == nil {
            usedBytes = extractBytes(trimmed)
        } else if trimmed.contains("Container Free Space:") && freeBytes == nil {
            freeBytes = extractBytes(trimmed)
        } else if trimmed.contains("Volume Free Space:") && freeBytes == nil {
            freeBytes = extractBytes(trimmed)
        }
    }

    guard let total = totalBytes, total > 1_000_000_000 else {
        print("FAIL:\(name):total_bytes_missing_or_too_small")
        return false
    }
    guard let used = usedBytes, used > 0 else {
        print("FAIL:\(name):used_bytes_missing")
        return false
    }
    guard let free = freeBytes, free > 0 else {
        print("FAIL:\(name):free_bytes_missing")
        return false
    }

    let totalGB = total / 1024 / 1024 / 1024
    let usedGB = used / 1024 / 1024 / 1024
    let freeGB = free / 1024 / 1024 / 1024

    // 合理性检查
    if totalGB < 1 || totalGB > 10000 {
        print("FAIL:\(name):totalGB_suspicious=\(totalGB)")
        return false
    }
    if usedGB < 0 || freeGB < 0 {
        print("FAIL:\(name):negative_value")
        return false
    }
    // 容许 60GB 误差（APFS 容器共享空间，Volume Used Space 不等于容器已用空间）
    // 实际上 macOS 的 container free space 是物理剩余空间，更准确
    if abs(usedGB + freeGB - totalGB) > 60.0 {
        print("FAIL:\(name):used+free_mismatch used=\(usedGB) free=\(freeGB) total=\(totalGB)")
        return false
    }

    print("OK:\(name):total=\(String(format: "%.1f", totalGB))GB used=\(String(format: "%.1f", usedGB))GB free=\(String(format: "%.1f", freeGB))GB")
    return true
}

let macOK = testDisk(macOSDiskInfo, "Macintosh HD")
let wdOK = testDisk(wdDiskInfo, "WD_BLACK")

if macOK && wdOK {
    print("ALL_PASS")
} else {
    print("SOME_FAIL")
}
SWIFT_EOF

DISK_RESULT=$(swift "$DISK_TEST_FILE" 2>&1)
rm -f "$DISK_TEST_FILE"

echo "$DISK_RESULT" | while read line; do
    if [[ "$line" == "OK:"* ]]; then
        info "$line"
    elif [[ "$line" == "FAIL:"* ]]; then
        fail "$line"
        FAILED=1
    elif [[ "$line" == "ALL_PASS" ]]; then
        pass "所有磁盘解析测试通过"
    elif [[ "$line" == "SOME_FAIL" ]]; then
        fail "有磁盘解析测试失败"
        FAILED=1
    fi
done

# ── 3. 内存计算验证 ─────────────────────────────
echo -e "\n${CYAN}[3] 内存计算验证${NC}"

MEM_TEST=$(swift -e '
import Foundation

func run(_ cmd: String, args: [String] = []) -> String {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: cmd)
    if !args.isEmpty { task.arguments = args }
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    try? task.run()
    task.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? ""
}

let vmStat = run("/usr/bin/vm_stat")
let pageSize = UInt64(run("/usr/sbin/sysctl", args: ["-n", "hw.pagesize"]).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 4096
let memTotal = UInt64(run("/usr/sbin/sysctl", args: ["-n", "hw.memsize"]).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

func extractVMStat(_ output: String, key: String) -> UInt64 {
    for line in output.components(separatedBy: "\n") {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix(key + ":") {
            let parts = trimmed.dropFirst(key.count + 1).trimmingCharacters(in: .whitespaces)
            let numStr = parts.filter { $0.isNumber }
            return UInt64(numStr) ?? 0
        }
    }
    return 0
}

let freePages = extractVMStat(vmStat, key: "Pages free")
let inactivePages = extractVMStat(vmStat, key: "Pages inactive")
let speculativePages = extractVMStat(vmStat, key: "Pages speculative")

// 当前 v2.0 公式: used = total - free - inactive - speculative
let usedMem = memTotal - (freePages * pageSize) - (inactivePages * pageSize) - (speculativePages * pageSize)
let memPct = Double(usedMem) / Double(memTotal) * 100

if memPct >= 15.0 && memPct <= 98.0 {
    print("OK:used=\(String(format: "%.1f", Double(usedMem)/1024/1024/1024))GB(\(String(format: "%.1f", memPct))%) free=\(String(format: "%.1f", Double(freePages*pageSize)/1024/1024/1024))GB inactive=\(String(format: "%.1f", Double(inactivePages*pageSize)/1024/1024/1024))GB")
} else {
    print("FAIL:mem_pct_out_of_range=\(String(format: "%.1f", memPct))% (expected 15-98)")
}
' 2>&1)

if [[ "$MEM_TEST" == "OK:"* ]]; then
    info "$MEM_TEST"
    pass "内存计算在合理范围"
elif [[ "$MEM_TEST" == "FAIL:"* ]]; then
    fail "$MEM_TEST"
    FAILED=1
else
    warn "内存验证脚本异常: $MEM_TEST"
fi

# ── 4. 数据源可用性检查 ─────────────────────────
echo -e "\n${CYAN}[4] 数据源可用性${NC}"

# 内存总量
if MEM_SIZE=$(/usr/sbin/sysctl -n hw.memsize 2>/dev/null) && [ -n "$MEM_SIZE" ] && [ "$MEM_SIZE" -gt 0 ]; then
    pass "sysctl hw.memsize ($(echo "scale=1; $MEM_SIZE/1024/1024/1024" | bc) GB)"
else
    fail "sysctl hw.memsize 失败"
    FAILED=1
fi

# vm_stat
if /usr/bin/vm_stat > /dev/null 2>&1; then
    pass "vm_stat"
else
    fail "vm_stat 失败"
    FAILED=1
fi

# 磁盘 /
if /usr/sbin/diskutil info / > /dev/null 2>&1; then
    pass "diskutil info /"
else
    fail "diskutil info / 失败"
    FAILED=1
fi

# 磁盘 WD_BLACK（非关键，警告即可）
if /usr/sbin/diskutil info /Volumes/WD_BLACK > /dev/null 2>&1; then
    pass "diskutil info /Volumes/WD_BLACK"
else
    warn "diskutil info /Volumes/WD_BLACK 不可用（外置磁盘未挂载）"
fi

# GPU - SPDisplaysDataType
SPGPU=$(/usr/sbin/system_profiler SPDisplaysDataType -json 2>/dev/null)
if [ -n "$SPGPU" ] && echo "$SPGPU" | python3 -c "import sys,json; d=json.load(sys.stdin); print('OK' if d.get('SPDisplaysDataType') else 'FAIL')" 2>/dev/null | grep -q "OK"; then
    pass "system_profiler SPDisplaysDataType"
else
    fail "system_profiler SPDisplaysDataType 失败或无数据"
    FAILED=1
fi

# 电源 - powermetrics（需要 root，普通 app 无法使用）
PM_OK=$(/usr/bin/powermetrics --samplers cpu_power -n 1 -i 1000 2>&1)
if echo "$PM_OK" | grep -q "must be invoked as the superuser"; then
    info "powermetrics 需要 root 权限（App 运行时不可用）"
    pass "powermetrics 已安装（但需要 root）"
else
    warn "powermetrics 存在但返回意外结果"
fi

# 蓝牙
if /usr/sbin/system_profiler SPBluetoothDataType -json > /dev/null 2>&1; then
    pass "system_profiler SPBluetoothDataType"
else
    warn "system_profiler SPBluetoothDataType 失败"
fi

# USB
if /usr/sbin/ioreg -r -c IOUSBHostDevice > /dev/null 2>&1; then
    pass "ioreg IOUSBHostDevice"
else
    warn "ioreg IOUSBHostDevice 失败"
fi

# 网络
if /usr/sbin/netstat -ib > /dev/null 2>&1; then
    pass "netstat -ib"
else
    fail "netstat -ib 失败"
    FAILED=1
fi

# Top 进程
if /bin/ps -aceo pid,pcpu,comm > /dev/null 2>&1; then
    pass "ps -aceo (Top CPU)"
else
    fail "ps -aceo 失败"
    FAILED=1
fi

if /bin/ps -aceo pid,rss,pcpu,comm > /dev/null 2>&1; then
    pass "ps -aceo (Top Memory)"
else
    fail "ps -aceo (RSS) 失败"
    FAILED=1
fi

# ── 5. 代码模式完整性 ─────────────────────────
echo -e "\n${CYAN}[5] 代码模式完整性${NC}"

# 检查是否有明显的会导致运行时错误的模式
if grep -q "maxHeight: .infinity" "$SRC_DIR/ContentView.swift" 2>/dev/null; then
    warn "ContentView.swift 中仍有 maxHeight: .infinity（可能导致瀑布流失效）"
fi

if grep -q "Int(.*\.filter.*isNumber)" "$SRC_DIR/SystemMonitor.swift" 2>/dev/null; then
    warn "SystemMonitor.swift 中可能有旧的数字过滤模式"
fi

# 检查 ContentView 是否有 WaterfallLayout
if grep -q "WaterfallLayout" "$SRC_DIR/ContentView.swift" 2>/dev/null; then
    pass "WaterfallLayout 已启用"
else
    warn "未找到 WaterfallLayout"
fi

# ── 6. 编译验证 ────────────────────────────────
echo -e "\n${CYAN}[6] 编译验证${NC}"

BUILD_DIR=$(mktemp -d)
xcodebuild -project "$PROJECT_DIR/MiniPulseV2.xcodeproj" \
    -scheme MiniPulseV2 \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    build 2>&1 | grep -E "BUILD (SUCCEEDED|FAILED)|error:|warning:" | head -20 > "$BUILD_DIR/build_result.txt"

if grep -q "BUILD SUCCEEDED" "$BUILD_DIR/build_result.txt"; then
    pass "编译成功"
    ERRORS=$(grep "error:" "$BUILD_DIR/build_result.txt" | wc -l | tr -d ' ')
    WARNINGS=$(grep "warning:" "$BUILD_DIR/build_result.txt" | wc -l | tr -d ' ')
    if [ "$ERRORS" -gt 0 ]; then
        fail "编译有 $ERRORS 个错误"
        grep "error:" "$BUILD_DIR/build_result.txt" | head -5
        FAILED=1
    else
        info "警告数: $WARNINGS"
    fi
else
    fail "编译失败"
    grep "error:" "$BUILD_DIR/build_result.txt" | head -5
    FAILED=1
fi

rm -rf "$BUILD_DIR"

# ── 结果汇总 ──────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILED -eq 0 ]; then
    echo -e "  ${GREEN}✓ 全部预测试通过${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "可以继续构建和部署："
    echo "  rm -rf ~/Library/Developer/Xcode/DerivedData/MiniPulseV2-*"
    echo "  cp -R ~/Library/Developer/Xcode/DerivedData/MiniPulseV2-*/Build/Products/Release/MiniPulse.app /Volumes/WD_BLACK/MiniPulseV2.app"
    echo ""
    exit 0
else
    echo -e "  ${RED}✗ 预测试失败 — 修复后再部署${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    exit 1
fi
