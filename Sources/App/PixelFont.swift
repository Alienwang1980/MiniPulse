import SwiftUI

// MARK: - Pixel Font Manager
// Fonts pre-installed via Homebrew Cask to ~/Library/Fonts/
// No manual registration needed - macOS auto-scans ~/Library/Fonts/

enum PixelFont {
    static let pressStart2P = "PressStart2P-Regular"
    static let vt323 = "VT323"

    /// Returns pixel font in 8-bit theme, system font otherwise.
    /// weight: .body = VT323 (readable), .title/.label = Press Start 2P (pixelated)
    static func eightBit(size: CGFloat, weight: PixelFontWeight) -> Font {
        isEightBit ? pixelFont(size: size, weight: weight) : .system(size: size)
    }

    static var isEightBit: Bool { AppTheme.shared.isEightBit }

    /// Press Start 2P has large x-height and wide glyphs — needs downscale to match
    /// the visual size of system font in Ocean Blue theme.
    private static func pixelFont(size: CGFloat, weight: PixelFontWeight) -> Font {
        let scaled: CGFloat
        if size >= 40 {
            scaled = size * 0.35
        } else if size >= 20 {
            scaled = size * 0.43
        } else {
            scaled = size * 0.62
        }
        return .custom(pressStart2P, size: max(scaled, 6))
    }

    enum PixelFontWeight {
        case label   // Press Start 2P - small labels
        case body    // Press Start 2P - body text
        case title   // Press Start 2P - medium titles
    }
}
