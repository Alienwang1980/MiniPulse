import SwiftUI

// MARK: - Pixel Font Manager
// Fonts loaded via Homebrew Cask — macOS auto-scans ~/Library/Fonts/
// Share Tech Mono, VT323, Orbitron installed there

enum PixelFont {
    // Three 8-bit font families — configurable
    static let mainFont   = "Silkscreen"      // 大数字（CPU % / GPU %）
    static let bodyFont   = "Silkscreen"      // 正文字体（标签、说明）
    static let displayFont = "Silkscreen"     // 展示字体（卡片标题）

    /// Returns pixel font in 8-bit theme, system font otherwise.
    /// - Parameters:
    ///   - size: The original size (no scaling applied)
    ///   - weight: Font weight — PixelFontWeight for 8-bit theme, Font.Weight for Ocean
    ///   - design: Font design (.default/.rounded/.monospaced) — ignored in 8-bit theme
    static func eightBit(size: CGFloat, weight: PixelFontWeight = .regular, design: Font.Design = .default) -> Font {
        if isEightBit {
            return pixelFont(size: size, weight: weight)
        } else {
            return .system(size: size, weight: weight.systemWeight, design: design)
        }
    }

    /// Overload with Font.Weight for cleaner call sites
    static func eightBit(size: CGFloat, weight: Font.Weight, design: Font.Design = .default) -> Font {
        if isEightBit {
            return pixelFont(size: size, weight: weight.pixelWeight)
        } else {
            return .system(size: size, weight: weight, design: design)
        }
    }

    static var isEightBit: Bool { AppTheme.shared.isEightBit }

    // MARK: - Private

    /// Maps PixelFontWeight → correct 8-bit font family
    private static func pixelFont(size: CGFloat, weight: PixelFontWeight) -> Font {
        let family: String
        switch weight {
        case .main, .title, .bold, .heavy, .black:
            family = mainFont
        case .display:
            family = displayFont
        case .semibold, .caption, .regular, .medium:
            family = bodyFont
        }
        print("[PixelFont] size=\(size) weight=\(weight) -> family=\(family)")
        return .custom(family, size: size)
    }

    // MARK: - Font Weight

    enum PixelFontWeight {
        case main     // VT323 — 超大数字（CPU/GPU % 数字）
        case title    // VT323 — 大标题
        case display  // Orbitron — 卡片标题 / Section 标题
        case bold     // VT323 — 大数字强调
        case semibold // Share Tech Mono — 副标题
        case regular  // Share Tech Mono — 正文
        case medium   // Share Tech Mono — 中等
        case caption  // Share Tech Mono — 小字
        case heavy    // VT323 — 超大强调
        case black    // VT323 — 最粗

        fileprivate var systemWeight: Font.Weight {
            switch self {
            case .main, .title, .display, .bold, .heavy, .black: return .bold
            case .semibold: return .semibold
            case .regular, .caption: return .regular
            case .medium:  return .medium
            }
        }
    }
}

// MARK: - Font.Weight Extension

extension Font.Weight {
    /// Maps Font.Weight → PixelFontWeight for 8-bit theme
    var pixelWeight: PixelFont.PixelFontWeight {
        switch self {
        case .ultraLight, .thin, .light:
            return .regular
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold, .heavy, .black:
            return .main  // 大数字用 VT323
        default:
            return .regular
        }
    }
}
