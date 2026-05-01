---

## P0 — `run()` Hang (FIXED, pending verification)

### Finding
`SystemMonitor.run()` used `semaphore.wait()` (unbounded) as the primary blocking mechanism. When `netstat -ib` hung due to Wi-Fi being disabled, the `terminationHandler` (set on `task.terminate()` via SIGKILL) sometimes did NOT fire due to a Darwin+Pipe interaction bug. This caused the semaphore to never be signaled, and the calling thread (and thus the entire timer callback) to block indefinitely.

**Evidence:** Diagnostic showed `netstatRaw` empty despite `knownIfaceNames` containing valid interfaces (`["en7", "lo0"]`). The refresh cycle was silently failing.

### Fix Applied
Changed `semaphore.wait()` → `semaphore.wait(timeout: .now() + timeout)`. On timeout, explicitly call `task.terminate()` then `Thread.sleep(0.05)` to allow the kernel to clean up pipe handles and deliver the termination notification. Returns whatever data was accumulated before the hang (or empty if terminated immediately).

### Verification Needed
Test on machine with Wi-Fi disabled. Monitor should show Ethernet interface stats without hanging.

---

## P0 — Temperature Debug File Written Every 5 Seconds

### Finding
`SystemMonitor.refresh()` (line 1672-1679) writes a debug file to `/tmp/minipulse_temp_debug.txt` on **every single refresh cycle** (every 5 seconds). This causes:
- Unnecessary disk I/O every 5s
- /tmp directory pollution
- Potential performance degradation from I/O on main timer thread
- Security/information leakage (system temperature data written to disk)

### Root Cause
Debug code was added during temperature sensor investigation and left in production without a feature flag or `#if DEBUG` guard.

### Fix Required
Remove the `try? debugLog.write(...)` block entirely. Temperature sensor data should only be captured on demand (via diagnostic report or dedicated debug mode).

### TDD Task
1. Search entire codebase for any remaining `minipulse_temp_debug` references
2. Remove the file writing code
3. Remove any corresponding debug flag/variable if only used for this
4. Verify: grep for "temp_debug" returns nothing

---

## P1 — `perIface` Empty Despite Valid Network Interfaces

### Finding
Even when `knownIfaceNames` contained valid interfaces and `netstat -ib` returned data, `perIface` was computed as empty. Root cause analysis:

1. `netStatOut = run("/usr/sbin/netstat", args: ["-ib"])` — when netstat hangs, returns empty string
2. `perIface` parsing loop (`for line in netStatOut.components...`) — empty string → zero iterations → empty dict
3. This was a **consequence of P0** (netstat hang). With P0 fixed, this should resolve.

### Secondary Issue: `ifaceTypeMap` Rebuilt Fresh Each Cycle
`ifaceTypeMap` is constructed from `ips` every refresh cycle. `ips` comes from `lastIfconfig` (updated every 60s). But `knownIfaceNames` accumulates across cycles via `formUnion`. This means:
- New interface detected via netstat → not in `ifaceTypeMap` → labeled with interface name instead of "Ethernet/Wi-Fi"
- The label for an interface can only be set on the cycle where `ifconfig` reports it

### TDD Task
1. Verify `perIface` populates correctly after P0 fix (Wi-Fi disabled → Ethernet shows per-device stats)
2. Verify interface labels ("Ethernet", "Wi-Fi") persist across refresh cycles
3. If `ifaceTypeMap` issue persists: pass `ifaceTypeMap` in `NetworkInfo` or use `knownIfaceNames` to look up from previous cycle's `ips`

---

## P1 — `BatteryCard` Logic Bug: `onBattery` Exclusion

### Finding
`BatteryInfo.onBattery` is set in `collectBatteryInfoViaIOKit()` as:
```swift
onBattery: !externalConnected && !isCharging
```

This means if the MacBook is charging (`isCharging = true`), `onBattery` is always `false`. This is correct. However, `BatteryCard.statusText` uses `displayedOnBattery` which comes from `battery?.onBattery`. The condition is correct.

BUT: The original bug before the fix was showing "未检测到电池" when `battery != nil && charging=false && onBattery=false`. This was fixed previously. The current logic is:
```swift
if displayedCharging { return "电源已接通" }
else if displayedOnBattery { return "电池供电" }
else { return "已接通" }
```
This is correct.

---

## P1 — `ssdTempC` Duplicates `gpuTempC` on Mac mini M4

### Finding
Lines 1661-1663 in `refresh()`:
```swift
cpuTemp = hidData.cpuDieTemp
gpuTemp = hidData.gpuDieTemp
ssdTemp = hidData.gpuDieTemp  // ← SAME SENSOR
```

On Mac mini M4, there's only one IOHID temperature sensor (`gpuDieTemp` / `nub-gpu-thermals`). Both GPU temp and SSD temp are assigned the same value. This means:
- SSD temp display shows GPU temp (wrong)
- GPU temp display is correct
- On MacBook Pro, `gpuDieTemp` is a separate sensor — this is correct

### Fix Required
Need per-platform sensor mapping. The correct approach:
- MacBook Pro: `gpuDieTemp` = GPU, `ssdTemp` needs separate NAND sensor
- Mac mini M4: `gpuDieTemp` = SSD (NAND), no GPU temp available

Sensor detection should be based on `machineModelName` or `hwModel`:
- `Mac16,10` (Mac mini M4) → assign `gpuDieTemp` to `ssdTemp`, `cpuDieTemp` to `cpuTemp`
- `MacBookPro` models → assign `cpuDieTemp` to `cpuTemp`, `gpuDieTemp` to `gpuTemp`, SSD temp = nil or separate NAND sensor

---

## P2 — Dead Code: Empty `HStack` Rows in `BatteryCard`

### Finding
Lines 152-157 of `BatteryCard.swift`:
```swift
HStack(spacing: 0) {
    Spacer()
    Spacer()
    Spacer()
    Spacer()
}
```
These are empty spacer rows that occupy vertical space but render nothing. They were likely intended as placeholders for additional metrics but were never populated.

### Fix
Remove these empty rows. The metric grid already has a second row (lines 146-151) that is also mostly empty — only the first BatteryMetric is visible. Review what the second row should contain:
- If no additional battery metrics exist → remove the second HStack entirely
- If metrics should exist → add them

---

## P2 — Disk Name Non-ASCII Filter Only at UI Layer

### Finding
`DiskCard.swift` lines 89 and 119 apply `.filter { $0.isASCII }` at display time:
```swift
Text(disk.name.filter { $0.isASCII })
```

This is a valid workaround but it should be at the **model layer** in `DiskInfo` or during the **disk collection** phase. Otherwise:
- Other UI views showing disk names need the same filter
- Debug logs/raw data still contain non-ASCII characters
- The filter hides Unicode characters (international disk labels) rather than handling them properly

### Fix
Apply `.filter { $0.isASCII }` when constructing `DiskInfo.name` in `performDiskCollection()`.

---

## P2 — GPU History Circular Buffer Logic

### Finding
Lines 1565-1577 implement a circular buffer for GPU history. The logic is complex and has potential off-by-one issues:
```swift
let count = min(gpuHistIdx, 20)
if gpuHistIdx < 20 {
    histSlice = Array(gpuHistory[0..<count])
} else {
    let head = gpuHistIdx % 20
    histSlice = Array(gpuHistory[head..<20]) + Array(gpuHistory[0..<head])
}
```

Issues:
- When `gpuHistIdx == 20` (first wrap), `count = 20`, `head = 0`, so `histSlice = gpuHistory[0..<20]` — correct
- When `gpuHistIdx == 21`, `count = 20`, `head = 1`, so `histSlice = gpuHistory[1..<20] + gpuHistory[0..<1]` — correct
- But the `histSlice` computation is repeated in two places and the initialization `gpuHistory = Array(repeating: 0, count: 20)` means the buffer starts with 20 zeros

### Fix
Simplify by using a straightforward ring buffer pattern. Swift's `Collection` has `rotated(by:)` or we can use a simple array append + drop approach.

---

## P2 — `print("[DISK] ...")` in Production Code

### Finding
Line 1536:
```swift
print("[DISK] performDiskCollection returned \(disks.count) disks: \(disks.map { $0.name })")
```

This `print()` statement runs on every refresh cycle (every 5 seconds). In a production macOS app, stdout is redirected to the system log, but it still incurs overhead and pollutes logs.

### Fix
Either:
1. Remove the print entirely
2. Wrap with `#if DEBUG` preprocessor macro

---
