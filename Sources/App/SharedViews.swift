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
                .font(PixelFont.eightBit(size: 13.2, weight: Font.Weight.medium))                .foregroundColor(color.opacity(0.7))
            Spacer()
            Text(value)
                .font(PixelFont.eightBit(size: 13.2, weight: Font.Weight.bold, design: .monospaced))                .foregroundColor(color)
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
                .font(PixelFont.eightBit(size: 12, weight: Font.Weight.medium))                .foregroundColor(theme.muted)
            Text(value)
                .font(PixelFont.eightBit(size: 14.4, weight: accent ? Font.Weight.bold : Font.Weight.medium))                .foregroundColor(accent ? theme.accent : theme.text)
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
                    (backgroundColor ?? theme.sparklineBg)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    FillWaveShape(points: points, count: count, height: geo.size.height)
                        .fill(
                            LinearGradient(
                                colors: [theme.accent2.opacity(0.45), theme.accent2.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    WaveLineShape(points: points)
                        .stroke(
                            theme.accent2.opacity(0.6),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                        )
                        .blur(radius: 2)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    WaveLineShape(points: points)
                        .stroke(
                            theme.accent2,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
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

// MARK: - Card Icon with Heartbeat
/// 卡片图标：处理 8-bit / SF Symbol 条件，数据更新时触发心跳动画
struct CardIcon<Trigger: Equatable>: View {
    let isEightBit: Bool
    let imageName: String       // 8-bit 图标资源名
    let sfSymbol: String        // SF Symbol 名
    let color: Color
    let trigger: Trigger
    var size: CGFloat = 40.3    // 默认 40.3，部分卡片用 37.4

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 1.0
    @State private var prevTrigger: Trigger?
    @State private var shrinkTimer: Timer?

    var body: some View {
        Group {
            if isEightBit {
                Image(imageName)
                    .resizable().scaledToFit().frame(width: 22, height: 22)
                    .font(PixelFont.eightBit(size: 16.8))
                    .foregroundColor(color)
                    .frame(width: size, height: size)
                    .background(color.opacity(0.20))
                    .cornerRadius(size * 0.24)
            } else {
                Image(systemName: sfSymbol)
                    .font(PixelFont.eightBit(size: 16.8))
                    .foregroundColor(color)
                    .frame(width: size, height: size)
                    .background(color.opacity(0.20))
                    .cornerRadius(size * 0.24)
            }
        }
        .scaleEffect(pulseScale)
        .opacity(pulseOpacity)
        .onChange(of: trigger) { newValue in
            guard newValue != prevTrigger else { return }
            prevTrigger = newValue
            // 停止之前的 timer
            shrinkTimer?.invalidate()
            // 顺滑跳大到峰值（0.08秒动画）
            withAnimation(.easeOut(duration: 0.08)) {
                pulseScale = 1.4
                pulseOpacity = 0.9
            }
            // 峰值稳定 0.08秒后，开始 5 秒线性缩小：1.4 → 0.7
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                let duration: TimeInterval = 5.0
                let fps: Double = 60.0
                let frames = Int(duration * fps)
                var frame = 0
                shrinkTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / fps, repeats: true) { timer in
                    frame += 1
                    let progress = min(1.0, Double(frame) / Double(frames))
                    pulseScale = 1.4 - (1.4 - 0.7) * progress  // 线性 1.4 → 0.7
                    pulseOpacity = 0.9 - (0.9 - 0.5) * progress  // 线性 0.9 → 0.5
                    if progress >= 1.0 {
                        pulseScale = 0.7
                        pulseOpacity = 0.5
                        timer.invalidate()
                    }
                }
            }
        }
        .onDisappear {
            shrinkTimer?.invalidate()
        }
    }
}
