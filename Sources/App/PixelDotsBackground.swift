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
            .fill(color.opacity(0.10))
            .offset(x: offsetX, y: offsetY)
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
