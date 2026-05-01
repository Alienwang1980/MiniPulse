import SwiftUI
import AppKit

// MARK: - NSVisualEffectView wrapper for proper blur
struct FrostedGlassView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow
    var blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
    var state: NSVisualEffectView.State = .active

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        view.wantsLayer = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (r, g, b) = (0, 0, 0)
        }
        self.init(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
}

// MARK: - Card Container with fade-in animation
struct CardContainer<Content: View>: View {
    let isVisible: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .opacity(isVisible ? 1 : 0)
            .animation(.easeOut(duration: 0.5), value: isVisible)
    }
}

// MARK: - Detail Row
// color is passed in by the parent card — no theme access needed here
struct DetailRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13.2, weight: .medium))
                .foregroundColor(color.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 13.2, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
    }
}

// MARK: - Info Cell
struct InfoCell: View {
    let label: String
    let value: String
    var accent: Bool = false

    private var theme: AppTheme { AppTheme.shared }

    var body: some View {
        VStack(alignment: .leading, spacing: 2.4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(theme.muted)
            Text(value)
                .font(.system(size: 14.4, weight: accent ? .bold : .medium))
                .foregroundColor(accent ? theme.accent : theme.text)
                .lineLimit(1)
        }
    }
}

// MARK: - Sparkline View
struct SparklineView: View {
    let history: [Int]
    var backgroundColor: Color? = nil  // nil = use theme.sparklineBg

    private var theme: AppTheme { AppTheme.shared }

    var body: some View {
        GeometryReader { geo in
            if history.count > 1 {
                let maxVal: CGFloat = 100
                let count = CGFloat(history.count)
                let stepX = geo.size.width / max(count - 1, 1)

                let points: [CGPoint] = history.enumerated().map { i, val in
                    CGPoint(
                        x: CGFloat(i) * stepX,
                        y: geo.size.height * (1 - CGFloat(val) / maxVal)
                    )
                }

                ZStack {
                    FillWaveShape(points: points, count: count, height: geo.size.height)
                        .fill(
                            LinearGradient(
                                colors: [theme.accent2.opacity(0.45), theme.accent2.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    WaveLineShape(points: points)
                        .stroke(
                            theme.accent2.opacity(0.6),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                        )
                        .blur(radius: 2)

                    WaveLineShape(points: points)
                        .stroke(
                            theme.accent2,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .background(backgroundColor ?? theme.sparklineBg)
    }
}

// ── Smooth bezier wave line ───────────────────────────────────────────────────
private struct WaveLineShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        guard points.count > 1 else { return Path() }
        var path = Path()
        path.move(to: points[0])

        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]
            let midX = (prev.x + curr.x) / 2
            path.addCurve(
                to: curr,
                control1: CGPoint(x: midX, y: prev.y),
                control2: CGPoint(x: midX, y: curr.y)
            )
        }
        return path
    }
}

// ── Filled area under the wave ───────────────────────────────────────────────
private struct FillWaveShape: Shape {
    let points: [CGPoint]
    let count: CGFloat
    let height: CGFloat

    func path(in rect: CGRect) -> Path {
        guard points.count > 1 else { return Path() }
        var path = Path()
        path.move(to: CGPoint(x: points[0].x, y: height))

        for i in 0..<points.count {
            if i == 0 {
                path.addLine(to: points[i])
            } else {
                let prev = points[i - 1]
                let curr = points[i]
                let midX = (prev.x + curr.x) / 2
                path.addCurve(
                    to: curr,
                    control1: CGPoint(x: midX, y: prev.y),
                    control2: CGPoint(x: midX, y: curr.y)
                )
            }
        }

        path.addLine(to: CGPoint(x: points[points.count - 1].x, y: height))
        path.closeSubpath()
        return path
    }
}
