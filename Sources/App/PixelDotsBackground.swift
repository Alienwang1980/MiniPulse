import SwiftUI

// MARK: - Pixel Dots Background Shape
// 8-bit theme background texture: evenly-spaced small dots.

struct PixelDotsShape: Shape {
    let dotSize: CGFloat
    let spacing: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cols = Int(rect.width / (dotSize + spacing)) + 1
        let rows = Int(rect.height / (dotSize + spacing)) + 1

        for row in 0..<rows {
            for col in 0..<cols {
                let x = CGFloat(col) * (dotSize + spacing) + spacing / 2
                let y = CGFloat(row) * (dotSize + spacing) + spacing / 2
                let dotRect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                path.addRect(dotRect)
            }
        }
        return path
    }
}

// MARK: - Multi-color Pixel Dots Background View
// Renders pixel dots in multiple accent colors at 10% opacity each.
// Used in 8-bit theme only.

struct PixelDotsBackground: View {
    let dotSize: CGFloat
    let spacing: CGFloat
    let isEightBit: Bool
    let isDark: Bool
    // Smaller, denser dots for card-level backgrounds
    static let cardDotSize: CGFloat = 1
    static let cardSpacing: CGFloat = 6

    // 6-color neon palette for dark mode, pastel for light mode
    private var darkColors: [Color] {
        [
            Color(hex: "E8A598"),  // coral
            Color(hex: "8ED8BE"),  // mint
            Color(hex: "F5D5A0"),  // peach
            Color(hex: "9DD3E8"),  // sky
            Color(hex: "C4B0E8"),  // lavender
            Color(hex: "C8C87A")   // olive
        ]
    }

    private var lightColors: [Color] {
        [
            Color(hex: "F5C4C4"),  // light coral
            Color(hex: "B8E8D8"),  // light mint
            Color(hex: "F0D890"),  // light peach
            Color(hex: "A0C8F0"),  // light sky
            Color(hex: "D0A8E8")   // light lavender
        ]
    }

    // Offset each color layer slightly to create a scattered multi-color effect
    private func dotLayer(color: Color, offsetX: CGFloat, offsetY: CGFloat) -> some View {
        PixelDotsShape(dotSize: dotSize, spacing: spacing)
            .fill(color.opacity(0.18))
            .offset(x: offsetX, y: offsetY)
    }

    // Convenience for card-level small dense dots
    static func cardDots(isEightBit: Bool, isDark: Bool) -> some View {
        if isEightBit {
            let colors = isDark ? [
                Color(hex: "E8A598"),
                Color(hex: "8ED8BE"),
                Color(hex: "F5D5A0"),
                Color(hex: "9DD3E8"),
                Color(hex: "C4B0E8"),
                Color(hex: "C8C87A")
            ] : [
                Color(hex: "F5C4C4"),
                Color(hex: "B8E8D8"),
                Color(hex: "F0D890"),
                Color(hex: "A0C8F0"),
                Color(hex: "D0A8E8")
            ]
            let offsets: [(CGFloat, CGFloat)] = [
                (0, 0), (3, 3), (6, 0), (9, 9), (12, 3), (15, 6)
            ]
            return AnyView(ZStack {
                ForEach(Array(zip(colors.indices, colors)), id: \.0) { index, color in
                    let offset = offsets[index % offsets.count]
                    PixelDotsShape(dotSize: cardDotSize, spacing: cardSpacing)
                        .fill(color.opacity(0.20))
                        .offset(x: offset.0, y: offset.1)
                }
            })
        } else {
            return AnyView(EmptyView())
        }
    }

    var body: some View {
        if isEightBit {
            let colors = isDark ? darkColors : lightColors
            let offsets: [(CGFloat, CGFloat)] = [
                (0, 0), (4, 4), (8, 0), (12, 12), (16, 4), (20, 8)
            ]

            ZStack {
                ForEach(Array(zip(colors.indices, colors)), id: \.0) { index, color in
                    let offset = offsets[index % offsets.count]
                    dotLayer(color: color, offsetX: offset.0, offsetY: offset.1)
                }
            }
        }
    }
}
