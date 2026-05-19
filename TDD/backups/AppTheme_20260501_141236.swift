import SwiftUI

// MARK: - Theme Type
enum ThemeType: String, CaseIterable {
    case ocean = "Ocean Blue"
    case eightBit = "8-bit"
}

// MARK: - AppTheme (@Observable)
@Observable
final class AppTheme {
    static let shared = AppTheme()

    private static let kThemeTypeKey = "MiniPulseV2.ThemeType"

    // ── colorScheme ────────────────────────────────────────────────
    var colorScheme: ColorScheme = .dark

    var isDark: Bool { colorScheme == .dark }

    var systemColorScheme: ColorScheme? = nil {
        didSet { if forcedColorScheme == nil { colorScheme = systemColorScheme ?? .dark } }
    }

    var forcedColorScheme: ColorScheme? = nil {
        didSet {
            if let forced = forcedColorScheme {
                colorScheme = forced
            } else {
                colorScheme = systemColorScheme ?? .dark
            }
        }
    }

    // ── Theme type (named themes) ──────────────────────────────────
    var themeType: ThemeType = .ocean {
        didSet {
            UserDefaults.standard.set(themeType.rawValue, forKey: Self.kThemeTypeKey)
        }
    }

    var isEightBit: Bool { themeType == .eightBit }

    // ── 8-bit 中性灰底色（背景用）───────────────────────────────
    // 深色: #1E1E1E，浅色: #F0F0F0
    private var eightBitBg:        Color { isDark ? Color(hex: "1E1E1E") : Color(hex: "F0F0F0") }
    private var eightBitSurface:   Color { isDark ? Color(hex: "1E1E1E") : Color(hex: "F0F0F0") }
    private var eightBitCard:      Color { isDark ? Color(hex: "2E2620") : Color(hex: "FFFFFF") }
    private var eightBitCardHover: Color { isDark ? Color(hex: "3A302A") : Color(hex: "FDF2E9") }
    private var eightBitBorder:    Color { isDark ? Color(hex: "3A302A") : Color(hex: "F0E0D0") }
    private var eightBitBorderHi:  Color { isDark ? Color(hex: "5A4E48") : Color(hex: "E8D5C4") }
    // ── 8-bit 通用文字色 ────────────────────────────────────────
    // 深色: #FFF5EB 暖白，浅色: #2D3436 深灰（已比背景暗，无需再降亮度）
    private var eightBitText:  Color { isDark ? Color(hex: "FFF5EB") : Color(hex: "2D3436") }
    private var eightBitMuted: Color { isDark ? Color(hex: "A09080") : Color(hex: "636E72") }

    // ── 8-bit Accent 6色相（每张卡片品牌色）────────────────────────
    // 深色模式: 霓虹亮色，浅色模式: 对应深色版本（亮度降低 20%）
    // 计算方式: HSL 保持色相，亮度 -20%
    private var eightBitCoral:     Color { isDark ? Color(hex: "E8A598") : Color(hex: "BA7A6E") }  // 珊瑚橙红
    private var eightBitMint:      Color { isDark ? Color(hex: "8ED8BE") : Color(hex: "5A9A82") }  // 薄荷绿
    private var eightBitPeach:     Color { isDark ? Color(hex: "F5D5A0") : Color(hex: "C4A870") }  // 蜜桃黄
    private var eightBitLavender:  Color { isDark ? Color(hex: "C4B0E8") : Color(hex: "9870B8") }  // 薰衣草紫
    private var eightBitSky:       Color { isDark ? Color(hex: "9DD3E8") : Color(hex: "6A9AB8") }  // 天蓝
    private var eightBitOlive:     Color { isDark ? Color(hex: "C8C87A") : Color(hex: "9A9A50") }  // 橄榄绿

    // ── 8-bit Status 色（按负载级别：低=绿黄，中=橙，高=红）────────
    private var eightBitLoadLow:    Color { isDark ? Color(hex: "8ED8BE") : Color(hex: "5A9A82") }   // 薄荷绿
    private var eightBitLoadMid:    Color { isDark ? Color(hex: "F5D5A0") : Color(hex: "C4A870") }   // 蜜桃黄
    private var eightBitLoadHigh:   Color { isDark ? Color(hex: "E8A598") : Color(hex: "BA7A6E") }  // 珊瑚红

    // ── 8-bit 卡片专属 accent（品牌色）────────────────────────────
    private var eightBitCpuAccent:       Color { eightBitCoral }    // 珊瑚红
    private var eightBitMemAccent:       Color { eightBitMint }     // 薄荷绿
    private var eightBitGpuAccent:       Color { eightBitPeach }    // 蜜桃黄
    private var eightBitNetAccent:       Color { eightBitSky }      // 天蓝
    private var eightBitDiskAccent:      Color { eightBitLavender } // 薰衣草紫
    private var eightBitBatteryAccent:    Color { eightBitOlive }    // 橄榄绿
    private var eightBitPowerAccent:     Color { eightBitCoral }    // 珊瑚红（台式机）
    private var eightBitBluetoothAccent:  Color { eightBitSky }      // 天蓝
    private var eightBitUsbAccent:       Color { eightBitLavender } // 薰衣草紫
    private var eightBitMachineAccent:    Color { eightBitPeach }   // 蜜桃黄
    private var eightBitTopAccent:       Color { eightBitMint }    // 薄荷绿

    // ── Ocean Blue palette (default) ────────────────────────────────
    private var oceanBg:        Color { isDark ? Color(hex: "080c14") : Color(hex: "e4eaf2") }
    private var oceanSurface:   Color { isDark ? Color(hex: "0d1525") : Color(hex: "f0f4f8") }
    private var oceanCard:      Color { isDark ? Color(hex: "111c32") : Color(hex: "ffffff") }
    private var oceanCardHover: Color { isDark ? Color(hex: "1a2845") : Color(hex: "e8eef5") }
    private var oceanBorder:    Color { isDark ? Color(hex: "1e3054") : Color(hex: "c8d4e3") }
    private var oceanBorderHi:  Color { isDark ? Color(hex: "2a4070") : Color(hex: "b0bdd0") }
    private var oceanText:      Color { isDark ? Color(hex: "e2e8f0") : Color(hex: "1e293b") }
    private var oceanMuted:     Color { isDark ? Color(hex: "64748b") : Color(hex: "5a6a7e") }
    private var oceanAccent:    Color { isDark ? Color(hex: "00d4ff") : Color(hex: "0077b6") }
    private var oceanAccent2:   Color { isDark ? Color(hex: "00e5cc") : Color(hex: "00838f") }
    private var oceanAccent3:   Color { isDark ? Color(hex: "7dd3fc") : Color(hex: "0369a1") }
    private var oceanGreen:     Color { isDark ? Color(hex: "34d399") : Color(hex: "16a34a") }
    private var oceanYellow:    Color { isDark ? Color(hex: "fbbf24") : Color(hex: "ca8a04") }
    private var oceanRed:       Color { isDark ? Color(hex: "f87171") : Color(hex: "dc2626") }
    private var oceanOrange:    Color { isDark ? Color(hex: "fb923c") : Color(hex: "c2410c") }
    private var oceanCyan:      Color { isDark ? Color(hex: "22d3ee") : Color(hex: "0891b2") }
    private var oceanCpuAccent:       Color { isDark ? Color(hex: "00d4ff") : Color(hex: "0077b6") }
    private var oceanMemAccent:       Color { isDark ? Color(hex: "a78bfa") : Color(hex: "6d28d9") }
    private var oceanGpuAccent:       Color { isDark ? Color(hex: "fb923c") : Color(hex: "c2410c") }
    private var oceanNetAccent:       Color { isDark ? Color(hex: "22d3ee") : Color(hex: "0891b2") }
    private var oceanDiskAccent:      Color { isDark ? Color(hex: "34d399") : Color(hex: "16a34a") }
    private var oceanBatteryAccent:   Color { isDark ? Color(hex: "fbbf24") : Color(hex: "ca8a04") }
    private var oceanPowerAccent:     Color { isDark ? Color(hex: "f87171") : Color(hex: "dc2626") }
    private var oceanBluetoothAccent: Color { isDark ? Color(hex: "818cf8") : Color(hex: "4338ca") }
    private var oceanUsbAccent:       Color { isDark ? Color(hex: "f472b6") : Color(hex: "be185d") }
    private var oceanMachineAccent:   Color { isDark ? Color(hex: "94a3b8") : Color(hex: "475569") }
    private var oceanTopAccent:       Color { isDark ? Color(hex: "7dd3fc") : Color(hex: "0369a1") }

    // ── Base / surface colors ─────────────────────────────────────
    var bg:        Color { themeType == .ocean ? oceanBg        : eightBitBg }
    var surface:   Color { themeType == .ocean ? oceanSurface   : eightBitSurface }
    var card:      Color { themeType == .ocean ? oceanCard      : eightBitCard }
    var cardHover: Color { themeType == .ocean ? oceanCardHover : eightBitCardHover }
    var border:    Color { themeType == .ocean ? oceanBorder    : eightBitBorder }
    var borderHi:  Color { themeType == .ocean ? oceanBorderHi  : eightBitBorderHi }

    // ── Progress bar background（浅色模式亮 60%）───────────────────
    // 8-bit: 深色 border=#4A3E38 → 浅色时提亮 60% → #E8E0D8
    // Ocean: 深色 border=#1E3054 → 浅色时提亮 60% → #D8E4F0
    private var eightBitProgressBarBg: Color {
        isDark ? eightBitBorder : Color(hex: "E8E0D8")
    }
    private var oceanProgressBarBg: Color {
        isDark ? oceanBorder : Color(hex: "D8E4F0")
    }
    var progressBarBg: Color { themeType == .ocean ? oceanProgressBarBg : eightBitBorder }

    // ── 8-bit 进度条渐变色（浅色模式提亮）────────────────────────
    // CPU: 深色 #0099ff → 浅色 #70C0FF
    private var eightBitCpuGrad2: Color { isDark ? Color(hex: "0099ff") : Color(hex: "70C0FF") }
    // Memory: 深色 #7c3aed → 浅色 #B080F0
    private var eightBitMemGrad2: Color { isDark ? Color(hex: "7c3aed") : Color(hex: "B080F0") }
    // Swap: 深色 #f87171/#ff1744 → 浅色 #FF9070/#FF5070
    private var eightBitSwapGrad1: Color { isDark ? Color(hex: "f87171") : Color(hex: "FF9070") }
    private var eightBitSwapGrad2: Color { isDark ? Color(hex: "ff1744") : Color(hex: "FF5070") }
    // Disk: 深色 #34d399/#16a34a → 浅色 #70E0A8/#50C080
    private var eightBitDiskGrad1: Color { isDark ? Color(hex: "34d399") : Color(hex: "70E0A8") }
    private var eightBitDiskGrad2: Color { isDark ? Color(hex: "16a34a") : Color(hex: "50C080") }
    // Disk 红色阈值（>90%）: 深色 #ff1744 → 浅色 #FF5070
    private var eightBitDiskRed: Color { isDark ? Color(hex: "ff1744") : Color(hex: "FF5070") }

    // Ocean 进度条渐变色（浅色模式提亮）
    private var oceanCpuGrad2: Color { isDark ? Color(hex: "0099ff") : Color(hex: "70C0FF") }
    private var oceanMemGrad2: Color { isDark ? Color(hex: "7c3aed") : Color(hex: "B080F0") }
    private var oceanSwapGrad1: Color { isDark ? Color(hex: "f87171") : Color(hex: "FF9070") }
    private var oceanSwapGrad2: Color { isDark ? Color(hex: "ff1744") : Color(hex: "FF5070") }
    private var oceanDiskGrad1: Color { isDark ? Color(hex: "34d399") : Color(hex: "70E0A8") }
    private var oceanDiskGrad2: Color { isDark ? Color(hex: "16a34a") : Color(hex: "50C080") }
    private var oceanDiskRed: Color { isDark ? Color(hex: "ff1744") : Color(hex: "FF5070") }

    // CPU Core 红色阈值（>80%）: 深色 #ff1744 → 浅色 #FF5070
    private var eightBitCpuRed: Color { isDark ? Color(hex: "ff1744") : Color(hex: "FF5070") }
    private var oceanCpuRed: Color { isDark ? Color(hex: "ff1744") : Color(hex: "FF5070") }

    // 公开访问
    var cpuGrad2:   Color { themeType == .ocean ? oceanCpuGrad2   : eightBitCpuGrad2 }
    var cpuRed:     Color { themeType == .ocean ? oceanCpuRed    : eightBitCpuRed }
    var memGrad2:   Color { themeType == .ocean ? oceanMemGrad2   : eightBitMemGrad2 }
    var swapGrad1:  Color { themeType == .ocean ? oceanSwapGrad1  : eightBitSwapGrad1 }
    var swapGrad2:  Color { themeType == .ocean ? oceanSwapGrad2  : eightBitSwapGrad2 }
    var diskGrad1:  Color { themeType == .ocean ? oceanDiskGrad1  : eightBitDiskGrad1 }
    var diskGrad2:  Color { themeType == .ocean ? oceanDiskGrad2  : eightBitDiskGrad2 }
    var diskRed:    Color { themeType == .ocean ? oceanDiskRed    : eightBitDiskRed }

    // ── Sparkline 背景（浅色模式提亮：opacity 0.2 → 0.4）──────────
    // 深色模式用 border 颜色本身（#3A302A，比背景 #2E2620 稍浅）
    var sparklineBg: Color { isDark ? border : border.opacity(0.4) }
    // ── 8-bit 通用文字色 ────────────────────────────────────────
    // 深色模式: 浅色暖白 #FFF5EB，浅色模式: 中性深灰 #2D3436
    var text:      Color { themeType == .ocean ? oceanText      : eightBitText }
    var muted:     Color { themeType == .ocean ? oceanMuted     : eightBitMuted }

    // ── 8-bit 通用 accent 别名（兼容旧代码）───────────────────────
    var accent:  Color { eightBitCoral }    // 品牌主色（珊瑚红）
    var accent2: Color { eightBitMint }    // 品牌辅色（薄荷绿）
    var accent3: Color { eightBitPeach }   // 品牌第三色（蜜桃黄）

    // ── 8-bit Load Status 色（按负载级别）─────────────────────────
    // 用法：progressBar 根据实际负载值选择 low/mid/high
    var loadLow:    Color { eightBitLoadLow }   // 低负载（薄荷绿）
    var loadMid:    Color { eightBitLoadMid }   // 中负载（蜜桃黄）
    var loadHigh:   Color { eightBitLoadHigh }  // 高负载（珊瑚红）

    // 兼容旧 ocean 色名的别名（8-bit 主题不需要这些）
    var green:  Color { eightBitLoadLow }
    var yellow: Color { eightBitLoadMid }
    var red:    Color { eightBitLoadHigh }
    var orange: Color { eightBitLoadMid }
    var cyan:   Color { eightBitSky }

    var cpuAccent:       Color { themeType == .ocean ? oceanCpuAccent       : eightBitCpuAccent }
    var cpuBright:       Color { themeType == .ocean ? oceanCpuAccent       : eightBitCoral }
    var memAccent:       Color { themeType == .ocean ? oceanMemAccent       : eightBitMemAccent }
    var gpuAccent:       Color { themeType == .ocean ? oceanGpuAccent       : eightBitGpuAccent }
    var netAccent:       Color { themeType == .ocean ? oceanNetAccent       : eightBitNetAccent }
    var diskAccent:      Color { themeType == .ocean ? oceanDiskAccent      : eightBitDiskAccent }
    var batteryAccent:   Color { themeType == .ocean ? oceanBatteryAccent   : eightBitBatteryAccent }
    var powerAccent:     Color { themeType == .ocean ? oceanPowerAccent     : eightBitPowerAccent }
    var bluetoothAccent: Color { themeType == .ocean ? oceanBluetoothAccent : eightBitBluetoothAccent }
    var usbAccent:       Color { themeType == .ocean ? oceanUsbAccent       : eightBitUsbAccent }
    var machineAccent:   Color { themeType == .ocean ? oceanMachineAccent   : eightBitMachineAccent }
    var topAccent:       Color { themeType == .ocean ? oceanTopAccent       : eightBitTopAccent }

    // ── 8-bit 卡片背景（对应 accent 色 + 20% 透明度，与图标背景一致）──
    // 深色/浅色模式下统一用对应 accent 色 + 0.20 opacity
    private var eightBitCpuCardBg:       Color { isDark ? Color(hex: "E8A598").opacity(0.20) : Color(hex: "BA7A6E").opacity(0.20) }
    private var eightBitMemCardBg:       Color { isDark ? Color(hex: "8ED8BE").opacity(0.20) : Color(hex: "5A9A82").opacity(0.20) }
    private var eightBitGpuCardBg:       Color { isDark ? Color(hex: "F5D5A0").opacity(0.20) : Color(hex: "C4A870").opacity(0.20) }
    private var eightBitNetCardBg:       Color { isDark ? Color(hex: "9DD3E8").opacity(0.20) : Color(hex: "6A9AB8").opacity(0.20) }
    private var eightBitDiskCardBg:      Color { isDark ? Color(hex: "C4B0E8").opacity(0.20) : Color(hex: "9870B8").opacity(0.20) }
    private var eightBitBatteryCardBg:   Color { isDark ? Color(hex: "C8C87A").opacity(0.20) : Color(hex: "9A9A50").opacity(0.20) }
    private var eightBitPowerCardBg:     Color { isDark ? Color(hex: "E8A598").opacity(0.20) : Color(hex: "BA7A6E").opacity(0.20) }
    private var eightBitBluetoothCardBg:  Color { isDark ? Color(hex: "9DD3E8").opacity(0.20) : Color(hex: "6A9AB8").opacity(0.20) }
    private var eightBitUsbCardBg:       Color { isDark ? Color(hex: "C4B0E8").opacity(0.20) : Color(hex: "9870B8").opacity(0.20) }
    private var eightBitMachineCardBg:   Color { isDark ? Color(hex: "F5D5A0").opacity(0.20) : Color(hex: "C4A870").opacity(0.20) }
    private var eightBitTopCardBg:       Color { isDark ? Color(hex: "8ED8BE").opacity(0.20) : Color(hex: "5A9A82").opacity(0.20) }

    var cpuCardBg:       Color { themeType == .ocean ? oceanCard : eightBitCpuCardBg }
    var memCardBg:       Color { themeType == .ocean ? oceanCard : eightBitMemCardBg }
    var gpuCardBg:       Color { themeType == .ocean ? oceanCard : eightBitGpuCardBg }
    var netCardBg:       Color { themeType == .ocean ? oceanCard : eightBitNetCardBg }
    var diskCardBg:      Color { themeType == .ocean ? oceanCard : eightBitDiskCardBg }
    var batteryCardBg:   Color { themeType == .ocean ? oceanCard : eightBitBatteryCardBg }
    var powerCardBg:     Color { themeType == .ocean ? oceanCard : eightBitPowerCardBg }
    var bluetoothCardBg: Color { themeType == .ocean ? oceanCard : eightBitBluetoothCardBg }
    var usbCardBg:       Color { themeType == .ocean ? oceanCard : eightBitUsbCardBg }
    var machineCardBg:   Color { themeType == .ocean ? oceanCard : eightBitMachineCardBg }
    var topCardBg:       Color { themeType == .ocean ? oceanCard : eightBitTopCardBg }

    private init() {
        loadTheme()
    }

    private func loadTheme() {
        if let saved = UserDefaults.standard.string(forKey: Self.kThemeTypeKey),
           let loaded = ThemeType(rawValue: saved) {
            themeType = loaded
        }
    }
}

/// Global convenience accessor
var theme: AppTheme { AppTheme.shared }
