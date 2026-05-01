import SwiftUI

// ─── Theme Protocol ─────────────────────────────────────────────────────────

/// 所有主题必须实现的协议。每张卡片的每行颜色代码只调用 theme.xxx，
/// 两个主题的值完全独立，互不干扰。
protocol Theme {
    // MARK: - 基础色
    var bg: Color { get }
    var surface: Color { get }
    var card: Color { get }
    var cardHover: Color { get }

    // MARK: - 文字色
    var text: Color { get }
    var muted: Color { get }

    // MARK: - Accent 别名（8-bit 使用最多，Ocean 只用 accent/accent2）
    var accent: Color { get }
    var accent2: Color { get }
    var accent3: Color { get }

    // MARK: - 边框/分割线
    var border: Color { get }
    var borderHi: Color { get }

    // MARK: - Status 色（绿色/黄色/红色）
    var green: Color { get }
    var yellow: Color { get }
    var red: Color { get }
    var orange: Color { get }
    var cyan: Color { get }

    // MARK: - 通用负载指示色
    var loadLow: Color { get }
    var loadMid: Color { get }
    var loadHigh: Color { get }

    // MARK: - Sparkline
    var sparklineBg: Color { get }
    var progressBarBg: Color { get }

    // MARK: - 卡片 Accent 实色（12 张卡片）
    var cpuAccent: Color { get }
    var memAccent: Color { get }
    var gpuAccent: Color { get }
    var netAccent: Color { get }
    var diskAccent: Color { get }
    var batteryAccent: Color { get }
    var powerAccent: Color { get }
    var bluetoothAccent: Color { get }
    var usbAccent: Color { get }
    var machineAccent: Color { get }
    var topAccent: Color { get }

    // MARK: - 卡片背景色（Accent 20%）
    var cpuCardBg: Color { get }
    var memCardBg: Color { get }
    var gpuCardBg: Color { get }
    var netCardBg: Color { get }
    var diskCardBg: Color { get }
    var batteryCardBg: Color { get }
    var powerCardBg: Color { get }
    var bluetoothCardBg: Color { get }
    var usbCardBg: Color { get }
    var machineCardBg: Color { get }
    var topCardBg: Color { get }

    // MARK: - CPU Core Bar 渐变
    var cpuGrad1: Color { get }
    var cpuGrad2: Color { get }
    var cpuLow: Color { get }
    var cpuRed: Color { get }

    // MARK: - Memory 渐变
    var memGrad1: Color { get }
    var memGrad2: Color { get }
    var swapGrad1: Color { get }
    var swapGrad2: Color { get }

    // MARK: - GPU 渐变
    var gpuGrad1: Color { get }
    var gpuGrad2: Color { get }

    // MARK: - Disk 渐变
    var diskGrad1: Color { get }
    var diskGrad2: Color { get }
    var diskRed: Color { get }
}

// ─── Ocean Theme ─────────────────────────────────────────────────────────────

struct OceanTheme: Theme {
    let isDark: Bool

    init(isDark: Bool) { self.isDark = isDark }

    // 基础色（来源：TDD/Ocean_Theme_Complete_Spec.md）
    var bg: Color { isDark ? Color(hex: "080c14") : Color(hex: "e4eaf2") }
    var surface: Color { isDark ? Color(hex: "0d1525") : Color(hex: "f0f4f8") }
    var card: Color { isDark ? Color(hex: "111c32") : Color(hex: "ffffff") }
    var cardHover: Color { isDark ? Color(hex: "1a2845") : Color(hex: "e8eef5") }

    // 文字色
    var text: Color { isDark ? Color(hex: "e2e8f0") : Color(hex: "1e293b") }
    var muted: Color { isDark ? Color(hex: "64748b") : Color(hex: "5a6a7e") }

    // Accent 别名（Ocean 核心：cyan 系）
    var accent: Color { isDark ? Color(hex: "00d4ff") : Color(hex: "0077b6") }
    var accent2: Color { isDark ? Color(hex: "00e5cc") : Color(hex: "00838f") }
    var accent3: Color { isDark ? Color(hex: "7dd3fc") : Color(hex: "0369a1") }

    // 边框/分割线
    var border: Color { isDark ? Color(hex: "1e3054") : Color(hex: "c8d4e3") }
    var borderHi: Color { isDark ? Color(hex: "2a4070") : Color(hex: "b0bdd0") }

    // Status 色
    var green: Color { isDark ? Color(hex: "34d399") : Color(hex: "16a34a") }
    var yellow: Color { isDark ? Color(hex: "fbbf24") : Color(hex: "ca8a04") }
    var red: Color { isDark ? Color(hex: "f87171") : Color(hex: "dc2626") }
    var orange: Color { isDark ? Color(hex: "fb923c") : Color(hex: "c2410c") }
    var cyan: Color { isDark ? Color(hex: "22d3ee") : Color(hex: "0891b2") }

    // 负载指示色
    var loadLow: Color { green }
    var loadMid: Color { yellow }
    var loadHigh: Color { red }

    // Sparkline（Ocean：深色用 border，浅色用 border @ 40%）
    var sparklineBg: Color { isDark ? border : border.opacity(0.4) }

    // 进度条背景（Ocean：深色用 border，浅色用 #D8E4F0）
    var progressBarBg: Color { isDark ? border : Color(hex: "D8E4F0") }

    // 卡片 Accent（Ocean 每张卡片独立 accent）
    var cpuAccent: Color { isDark ? Color(hex: "00d4ff") : Color(hex: "0077b6") }
    var memAccent: Color { isDark ? Color(hex: "a78bfa") : Color(hex: "6d28d9") }
    var gpuAccent: Color { isDark ? Color(hex: "4ADE80") : Color(hex: "10B981") }
    var netAccent: Color { isDark ? Color(hex: "22d3ee") : Color(hex: "0891b2") }
    var diskAccent: Color { isDark ? Color(hex: "34d399") : Color(hex: "16a34a") }
    var batteryAccent: Color { isDark ? Color(hex: "fbbf24") : Color(hex: "ca8a04") }
    var powerAccent: Color { isDark ? Color(hex: "f87171") : Color(hex: "dc2626") }
    var bluetoothAccent: Color { isDark ? Color(hex: "818cf8") : Color(hex: "4338ca") }
    var usbAccent: Color { isDark ? Color(hex: "f472b6") : Color(hex: "be185d") }
    var machineAccent: Color { isDark ? Color(hex: "94a3b8") : Color(hex: "475569") }
    var topAccent: Color { isDark ? Color(hex: "7dd3fc") : Color(hex: "0369a1") }

    // 卡片背景（Ocean = accent@20%，Ocean卡片背景统一用 card）
    var cpuCardBg: Color { cpuAccent.opacity(0.20) }
    var memCardBg: Color { memAccent.opacity(0.20) }
    var gpuCardBg: Color { gpuAccent.opacity(0.20) }
    var netCardBg: Color { netAccent.opacity(0.20) }
    var diskCardBg: Color { diskAccent.opacity(0.20) }
    var batteryCardBg: Color { batteryAccent.opacity(0.20) }
    var powerCardBg: Color { powerAccent.opacity(0.20) }
    var bluetoothCardBg: Color { bluetoothAccent.opacity(0.20) }
    var usbCardBg: Color { usbAccent.opacity(0.20) }
    var machineCardBg: Color { machineAccent.opacity(0.20) }
    var topCardBg: Color { topAccent.opacity(0.20) }

    // CPU Core Bar 渐变（Ocean cyan→blue）
    var cpuGrad1: Color { isDark ? Color(hex: "00d4ff") : Color(hex: "70C0FF") }
    var cpuGrad2: Color { isDark ? Color(hex: "0099ff") : Color(hex: "0077b6") }
    var cpuLow: Color { isDark ? Color(hex: "00d4ff") : Color(hex: "16a34a") }
    var cpuRed: Color { isDark ? Color(hex: "ff1744") : Color(hex: "FF5070") }

    // Memory 渐变（Ocean purple 系）
    var memGrad1: Color { isDark ? Color(hex: "a78bfa") : Color(hex: "B080F0") }
    var memGrad2: Color { isDark ? Color(hex: "7c3aed") : Color(hex: "7c3aed") }
    var swapGrad1: Color { isDark ? Color(hex: "f87171") : Color(hex: "FF9070") }
    var swapGrad2: Color { isDark ? Color(hex: "ff1744") : Color(hex: "FF5070") }

    // GPU 渐变（Ocean green 系）
    var gpuGrad1: Color { isDark ? Color(hex: "22C55E") : Color(hex: "16A34A") }
    var gpuGrad2: Color { isDark ? Color(hex: "4ADE80") : Color(hex: "10B981") }

    // Disk 渐变（Ocean green 系）
    var diskGrad1: Color { isDark ? Color(hex: "34d399") : Color(hex: "70E0A8") }
    var diskGrad2: Color { isDark ? Color(hex: "16a34a") : Color(hex: "50C080") }
    var diskRed: Color { isDark ? Color(hex: "ff1744") : Color(hex: "FF5070") }
}

// ─── 8-bit Theme ─────────────────────────────────────────────────────────────

struct EightBitTheme: Theme {
    let isDark: Bool

    init(isDark: Bool) { self.isDark = isDark }

    // 基础色
    var bg: Color { isDark ? Color(hex: "1E1E1E") : Color(hex: "F0F0F0") }
    var surface: Color { isDark ? Color(hex: "1E1E1E") : Color(hex: "F0F0F0") }
    var card: Color { isDark ? Color(hex: "2E2620") : Color(hex: "FFFFFF") }
    var cardHover: Color { isDark ? Color(hex: "3A302A") : Color(hex: "FDF2E9") }

    // 文字色
    var text: Color { isDark ? Color(hex: "FFF5EB") : Color(hex: "2D3436") }
    var muted: Color { isDark ? Color(hex: "A09080") : Color(hex: "636E72") }

    // Accent 别名
    var accent: Color { isDark ? Color(hex: "E8A598") : Color(hex: "BA7A6E") }
    var accent2: Color { isDark ? Color(hex: "8ED8BE") : Color(hex: "5A9A82") }
    var accent3: Color { isDark ? Color(hex: "F5D5A0") : Color(hex: "C4A870") }

    // 边框/分割线（8-bit 暖色调）
    var border: Color { isDark ? Color(hex: "3A302A") : Color(hex: "F0E0D0") }
    var borderHi: Color { isDark ? Color(hex: "5A4E48") : Color(hex: "E8D5C4") }

    // Status 色
    var green: Color { isDark ? Color(hex: "8ED8BE") : Color(hex: "5A9A82") }
    var yellow: Color { isDark ? Color(hex: "F5D5A0") : Color(hex: "C4A870") }
    var red: Color { isDark ? Color(hex: "E8A598") : Color(hex: "BA7A6E") }
    var orange: Color { isDark ? Color(hex: "F5D5A0") : Color(hex: "C4A870") }
    var cyan: Color { isDark ? Color(hex: "9DD3E8") : Color(hex: "6A9AB8") }

    // 负载指示色
    var loadLow: Color { green }
    var loadMid: Color { yellow }
    var loadHigh: Color { red }

    // Sparkline（8-bit 深色用 borderHi，浅色用 #E8F4EE）
    var sparklineBg: Color { isDark ? borderHi.opacity(0.7) : Color(hex: "E8F4EE") }

    // 进度条背景（8-bit：icon容器色 accent@20%，与卡片背景同色）
    var progressBarBg: Color { isDark ? Color(hex: "E8A598").opacity(0.20) : Color(hex: "BA7A6E").opacity(0.20) }

    // 卡片 Accent 实色（各色独立）
    var cpuAccent: Color { isDark ? Color(hex: "E8A598") : Color(hex: "BA7A6E") }
    var memAccent: Color { isDark ? Color(hex: "8ED8BE") : Color(hex: "5A9A82") }
    var gpuAccent: Color { isDark ? Color(hex: "4ADE80") : Color(hex: "10B981") }
    var netAccent: Color { isDark ? Color(hex: "9DD3E8") : Color(hex: "6A9AB8") }
    var diskAccent: Color { isDark ? Color(hex: "C4B0E8") : Color(hex: "9870B8") }
    var batteryAccent: Color { isDark ? Color(hex: "C8C87A") : Color(hex: "9A9A50") }
    var powerAccent: Color { isDark ? Color(hex: "E8A598") : Color(hex: "BA7A6E") }
    var bluetoothAccent: Color { isDark ? Color(hex: "9DD3E8") : Color(hex: "6A9AB8") }
    var usbAccent: Color { isDark ? Color(hex: "C4B0E8") : Color(hex: "9870B8") }
    var machineAccent: Color { isDark ? Color(hex: "F5D5A0") : Color(hex: "C4A870") }
    var topAccent: Color { isDark ? Color(hex: "8ED8BE") : Color(hex: "5A9A82") }

    // 卡片背景（Accent 20%）
    var cpuCardBg: Color { cpuAccent.opacity(0.20) }
    var memCardBg: Color { memAccent.opacity(0.20) }
    var gpuCardBg: Color { gpuAccent.opacity(0.20) }
    var netCardBg: Color { netAccent.opacity(0.20) }
    var diskCardBg: Color { diskAccent.opacity(0.20) }
    var batteryCardBg: Color { batteryAccent.opacity(0.20) }
    var powerCardBg: Color { batteryAccent.opacity(0.20) }
    var bluetoothCardBg: Color { bluetoothAccent.opacity(0.20) }
    var usbCardBg: Color { usbAccent.opacity(0.20) }
    var machineCardBg: Color { machineAccent.opacity(0.20) }
    var topCardBg: Color { topAccent.opacity(0.20) }

    // CPU Core Bar 渐变（8-bit 暖色系）
    var cpuGrad1: Color { isDark ? Color(hex: "E8A598") : Color(hex: "BA7A6E") }
    var cpuGrad2: Color { isDark ? Color(hex: "0099FF") : Color(hex: "70C0FF") }
    var cpuLow: Color { isDark ? Color(hex: "E8A598") : Color(hex: "F5D5A0") }
    var cpuRed: Color { isDark ? Color(hex: "ff1744") : Color(hex: "FF5070") }

    // Memory 渐变（8-bit 绿→紫）
    var memGrad1: Color { isDark ? Color(hex: "8ED8BE") : Color(hex: "5A9A82") }
    var memGrad2: Color { isDark ? Color(hex: "7c3aed") : Color(hex: "B080F0") }
    var swapGrad1: Color { isDark ? Color(hex: "f87171") : Color(hex: "FF9070") }
    var swapGrad2: Color { isDark ? Color(hex: "ff1744") : Color(hex: "FF5070") }

    // GPU 渐变（8-bit 绿色系）
    var gpuGrad1: Color { isDark ? Color(hex: "22C55E") : Color(hex: "16A34A") }
    var gpuGrad2: Color { isDark ? Color(hex: "4ADE80") : Color(hex: "10B981") }

    // Disk 渐变（8-bit 绿→紫，与内存相同）
    var diskGrad1: Color { isDark ? Color(hex: "8ED8BE") : Color(hex: "5A9A82") }
    var diskGrad2: Color { isDark ? Color(hex: "7c3aed") : Color(hex: "B080F0") }
    var diskRed: Color { isDark ? Color(hex: "ff1744") : Color(hex: "FF5070") }
}

// ─── ThemeType ───────────────────────────────────────────────────────────────

enum ThemeType: String, CaseIterable {
    case ocean = "Ocean"
    case eightBit = "8-bit"
}

// ─── AppTheme ────────────────────────────────────────────────────────────────

/// AppTheme 是整个主题系统的入口。它是一个 @Observable 单例，
/// 负责维护 themeType（用户选择）和 colorScheme（系统外观），
/// 并将这两个维度映射到具体的 Theme（OceanTheme 或 EightBitTheme）。
@Observable
final class AppTheme {
    static let shared = AppTheme()

    // 用户选择的主题类型
    var themeType: ThemeType = .ocean

    // 系统外观（由 ContentView 注入）
    var systemColorScheme: ColorScheme = .dark

    // 是否强制手动切换（不在此架构中使用，保留接口兼容）
    var forcedColorScheme: ColorScheme? = nil

    /// 当前生效的 ColorScheme（强制值 > 系统值）
    var colorScheme: ColorScheme {
        forcedColorScheme ?? systemColorScheme
    }

    /// 当前主题（协议存在类型）
    var currentTheme: any Theme {
        let isDark = colorScheme == .dark
        switch themeType {
        case .ocean:   return OceanTheme(isDark: isDark)
        case .eightBit: return EightBitTheme(isDark: isDark)
        }
    }

    // ── 便捷计算属性 ────────────────────────────────────────────────────────

    var isDark: Bool { colorScheme == .dark }
    var isEightBit: Bool { themeType == .eightBit }

    // 委托给 currentTheme（每张卡片使用 theme.xxx 访问这些）
    var bg: Color { currentTheme.bg }
    var surface: Color { currentTheme.surface }
    var card: Color { currentTheme.card }
    var cardHover: Color { currentTheme.cardHover }
    var text: Color { currentTheme.text }
    var muted: Color { currentTheme.muted }
    var accent: Color { currentTheme.accent }
    var accent2: Color { currentTheme.accent2 }
    var accent3: Color { currentTheme.accent3 }
    var border: Color { currentTheme.border }
    var borderHi: Color { currentTheme.borderHi }
    var green: Color { currentTheme.green }
    var yellow: Color { currentTheme.yellow }
    var red: Color { currentTheme.red }
    var orange: Color { currentTheme.orange }
    var cyan: Color { currentTheme.cyan }
    var loadLow: Color { currentTheme.loadLow }
    var loadMid: Color { currentTheme.loadMid }
    var loadHigh: Color { currentTheme.loadHigh }
    var sparklineBg: Color { currentTheme.sparklineBg }
    var progressBarBg: Color { currentTheme.progressBarBg }
    var cpuAccent: Color { currentTheme.cpuAccent }
    var memAccent: Color { currentTheme.memAccent }
    var gpuAccent: Color { currentTheme.gpuAccent }
    var netAccent: Color { currentTheme.netAccent }
    var diskAccent: Color { currentTheme.diskAccent }
    var batteryAccent: Color { currentTheme.batteryAccent }
    var powerAccent: Color { currentTheme.powerAccent }
    var bluetoothAccent: Color { currentTheme.bluetoothAccent }
    var usbAccent: Color { currentTheme.usbAccent }
    var machineAccent: Color { currentTheme.machineAccent }
    var topAccent: Color { currentTheme.topAccent }
    var cpuCardBg: Color { currentTheme.cpuCardBg }
    var memCardBg: Color { currentTheme.memCardBg }
    var gpuCardBg: Color { currentTheme.gpuCardBg }
    var netCardBg: Color { currentTheme.netCardBg }
    var diskCardBg: Color { currentTheme.diskCardBg }
    var batteryCardBg: Color { currentTheme.batteryCardBg }
    var powerCardBg: Color { currentTheme.powerCardBg }
    var bluetoothCardBg: Color { currentTheme.bluetoothCardBg }
    var usbCardBg: Color { currentTheme.usbCardBg }
    var machineCardBg: Color { currentTheme.machineCardBg }
    var topCardBg: Color { currentTheme.topCardBg }
    var cpuGrad1: Color { currentTheme.cpuGrad1 }
    var cpuGrad2: Color { currentTheme.cpuGrad2 }
    var cpuLow: Color { currentTheme.cpuLow }
    var cpuRed: Color { currentTheme.cpuRed }
    var memGrad1: Color { currentTheme.memGrad1 }
    var memGrad2: Color { currentTheme.memGrad2 }
    var swapGrad1: Color { currentTheme.swapGrad1 }
    var swapGrad2: Color { currentTheme.swapGrad2 }
    var gpuGrad1: Color { currentTheme.gpuGrad1 }
    var gpuGrad2: Color { currentTheme.gpuGrad2 }
    var diskGrad1: Color { currentTheme.diskGrad1 }
    var diskGrad2: Color { currentTheme.diskGrad2 }
    var diskRed: Color { currentTheme.diskRed }

    private init() {}
}
