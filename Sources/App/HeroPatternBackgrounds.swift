import SwiftUI

// MARK: - Hero Patterns: Programmatic SVG-style background patterns
// CC BY 4.0 — https://heropatterns.com/
// Implemented as SwiftUI Shapes for use as card-level backgrounds.
// Each pattern takes a foreground color and renders at low opacity.

// ============================================================
// HERO PATTERN TYPE ENUM — standalone, used by both CardHeroPattern and HeroPatternBackground
// ============================================================
enum HeroPatternType: CaseIterable {
    case graphPaper
    case diagonalLines
    case polkaDots
    case waves
    case piazza
    case pixelDots  // from PixelDotsBackground.swift

    static func random() -> HeroPatternType {
        allCases.randomElement()!
    }
}

// ============================================================
// CARD PATTERN ASSIGNMENTS — Fixed per card for 8-bit theme
// ============================================================
enum CardHeroPattern {
    static let cpu     = HeroPatternType.graphPaper
    static let memory  = HeroPatternType.diagonalLines
    static let gpu     = HeroPatternType.polkaDots
    static let network = HeroPatternType.waves
    static let power   = HeroPatternType.piazza
    static let battery = HeroPatternType.graphPaper
    static let disk    = HeroPatternType.diagonalLines
}

// ============================================================
// 1. GRAPH PAPER — pixel grid
// ============================================================
struct GraphPaperPattern: Shape {
    let gridSize: CGFloat
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        var x: CGFloat = 0
        while x <= rect.width {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
            x += gridSize
        }
        var y: CGFloat = 0
        while y <= rect.height {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
            y += gridSize
        }
        return path
    }
}

// ============================================================
// 2. DIAGONAL LINES — simple diagonal stripes
// ============================================================
struct DiagonalLinesPattern: Shape {
    let spacing: CGFloat
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let d = spacing
        let w = lineWidth
        let diag = sqrt(rect.width * rect.width + rect.height * rect.height)

        var x = -diag
        while x < rect.width + diag {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x + rect.height, y: rect.height))
            x += d
        }
        return path.strokedPath(StrokeStyle(lineWidth: w, lineCap: .butt))
    }
}

// ============================================================
// 3. POLKA DOTS — evenly spaced circles
// ============================================================
struct PolkaDotsPattern: Shape {
    let dotSize: CGFloat
    let spacing: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cols = Int(rect.width / (dotSize + spacing)) + 2
        let rows = Int(rect.height / (dotSize + spacing)) + 2
        let r = dotSize / 2

        for row in 0..<rows {
            let xOffset: CGFloat = (row % 2 == 0) ? 0 : (dotSize + spacing) / 2
            for col in 0..<cols {
                let cx = CGFloat(col) * (dotSize + spacing) + xOffset + r
                let cy = CGFloat(row) * (dotSize + spacing) + r
                path.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: dotSize, height: dotSize))
            }
        }
        return path
    }
}

// ============================================================
// 4. WAVES — horizontal wavy lines
// ============================================================
struct WavesPattern: Shape {
    let waveHeight: CGFloat
    let waveLength: CGFloat
    let lineWidth: CGFloat
    let spacing: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        var y: CGFloat = 0
        while y < rect.height + waveHeight {
            path.move(to: CGPoint(x: 0, y: y))
            var x: CGFloat = 0
            while x < rect.width + waveLength {
                path.addQuadCurve(
                    to: CGPoint(x: x + waveLength / 2, y: y - waveHeight),
                    control: CGPoint(x: x + waveLength / 4, y: y - waveHeight)
                )
                path.addQuadCurve(
                    to: CGPoint(x: x + waveLength, y: y),
                    control: CGPoint(x: x + waveLength * 3 / 4, y: y - waveHeight)
                )
                x += waveLength
            }
            y += spacing
        }
        return path
    }
}

// ============================================================
// 5. PIAZZA — square grid dots
// ============================================================
struct PiazzaPattern: Shape {
    let dotSize: CGFloat
    let spacing: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cols = Int(rect.width / (dotSize + spacing)) + 2
        let rows = Int(rect.height / (dotSize + spacing)) + 2
        let r = dotSize / 2

        for row in 0..<rows {
            for col in 0..<cols {
                let cx = CGFloat(col) * (dotSize + spacing) + r
                let cy = CGFloat(row) * (dotSize + spacing) + r
                path.addRect(CGRect(x: cx - r, y: cy - r, width: dotSize, height: dotSize))
            }
        }
        return path
    }
}

// ============================================================
// PATTERN WRAPPER: Applies a Hero Pattern as card background
// ============================================================
struct HeroPatternBackground: View {
    let pattern: HeroPatternType
    let color: Color
    let opacity: Double

    var body: some View {
        Group {
            switch pattern {
            case .graphPaper:
                GraphPaperPattern(gridSize: 12, lineWidth: 0.5)
                    .stroke(color, lineWidth: 0.5)
            case .diagonalLines:
                DiagonalLinesPattern(spacing: 10, lineWidth: 1.5)
                    .fill(color)
            case .polkaDots:
                PolkaDotsPattern(dotSize: 4, spacing: 12)
                    .fill(color)
            case .waves:
                WavesPattern(waveHeight: 6, waveLength: 20, lineWidth: 1.5, spacing: 12)
                    .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            case .piazza:
                PiazzaPattern(dotSize: 2, spacing: 8)
                    .fill(color)
            case .pixelDots:
                PixelDotsBackground.cardDots(isEightBit: true, isDark: true)
            }
        }
        .opacity(opacity)
    }
}
