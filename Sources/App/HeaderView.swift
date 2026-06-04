import SwiftUI

// MARK: - LiquidGlassHeader Background

/// Native Liquid Glass background for macOS 26+ using SwiftUI glassEffect
@available(macOS 26.0, *)
struct LiquidGlassHeaderBackground: View {
    var body: some View {
        Rectangle()
            .fill(.clear)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassEffect(.regular, in: Rectangle())
    }
}

/// Fallback for macOS < 26 — uses standard FrostedGlassView
struct LegacyGlassBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .withinWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = .hudWindow
        if AppTheme.shared.colorScheme == .light {
            nsView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.65).cgColor
        }
    }
}

// MARK: - Header

struct HeaderView: View {
    let sysInfo: SysInfo
    let cpu: CpuInfo
    let temps: TempInfo
    @Binding var showEditOrder: Bool

    @State private var pulseBgOpacity: Double = 0.15
    @State private var pulseScale: CGFloat = 1.0
    @State private var prevCpuPercent: Double = 0
    @State private var shrinkTimer: Timer?

    private var theme: AppTheme { AppTheme.shared }

    private var deviceIcon: String {
        sysInfo.isLaptop ? "laptopcomputer" : "desktopcomputer"
    }

    private func triggerPulse() {
        shrinkTimer?.invalidate()
        withAnimation(.easeOut(duration: 0.1)) {
            pulseBgOpacity = 0.35
            pulseScale = 1.12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let duration: TimeInterval = 2.5
            let fps: Double = 60.0
            let frames = Int(duration * fps)
            var frame = 0
            shrinkTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / fps, repeats: true) { timer in
                frame += 1
                let progress = min(1.0, Double(frame) / Double(frames))
                pulseBgOpacity = 0.35 - (0.35 - 0.10) * progress
                pulseScale = 1.12 - (1.12 - 1.0) * progress
                if progress >= 1.0 {
                    pulseBgOpacity = 0.10
                    pulseScale = 1.0
                    timer.invalidate()
                }
            }
        }
    }

    var body: some View {
        HStack(spacing: 16.8) {
            // Left: device icon with pulsing background (only background scales, icon stays fixed)
            ZStack {
                Image(systemName: deviceIcon)
                    .font(PixelFont.eightBit(size: 31.2))
                    .foregroundColor(theme.accent)
                    .frame(width: 62.4, height: 62.4)

                Circle()
                    .fill(theme.accent.opacity(pulseBgOpacity))
                    .frame(width: 62.4, height: 62.4)
                    .scaleEffect(pulseScale)
            }
            .frame(width: 62.4, height: 62.4)

            // Left-center: user name + machine model (same row), then uptime (scaled 20%)
            VStack(alignment: .leading, spacing: 4.8) {
                HStack(spacing: 12) {
                    Text(sysInfo.userName.isEmpty ? "用户" : sysInfo.userName)
                        .font(PixelFont.eightBit(size: 28.8, weight: Font.Weight.bold, design: .rounded))                        .foregroundColor(theme.text)
                    Text(sysInfo.machineModelName)
                        .font(PixelFont.eightBit(size: 28.8, weight: Font.Weight.bold, design: .rounded))                        .foregroundColor(theme.muted)
                }
                Text("运行时长: \(sysInfo.uptime)")
                    .font(PixelFont.eightBit(size: 16.8, weight: Font.Weight.medium, design: .monospaced))                    .foregroundColor(theme.muted)
            }

            Spacer()

            // Right: broadcast indicator + edit button
            HStack(spacing: 12) {
                // Broadcast status icon
                Image(systemName: HostManager.shared.broadcastingEnabled
                    ? "antenna.radiowaves.left.and.right"
                    : "antenna.radiowaves.left.and.right.slash")
                    .font(PixelFont.eightBit(size: 16.8))
                    .foregroundColor(HostManager.shared.broadcastingEnabled ? theme.green : theme.muted)
                    .help(HostManager.shared.broadcastingEnabled ? "广播中" : "广播已关闭")

                Button(action: { showEditOrder = true }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(PixelFont.eightBit(size: 16.8))                        .foregroundColor(theme.muted)
                }
                .buttonStyle(.plain)
            }

            // Logo
            Image(theme.colorScheme == .dark ? "logo_dark" : "logo_light")
                .resizable()
                .scaledToFit()
                .frame(height: 75)
        }
        .padding(.horizontal, 28.8)
        .frame(height: 120)
        .background {
            if #available(macOS 26.0, *) {
                if theme.colorScheme == .light {
                    LiquidGlassHeaderBackground()
                } else {
                    LegacyGlassBackground()
                }
            } else {
                LegacyGlassBackground()
            }
        }
        .onAppear { prevCpuPercent = cpu.percent }
        .onChange(of: cpu.percent) { _, newVal in
            if newVal != prevCpuPercent {
                prevCpuPercent = newVal
                triggerPulse()
            }
        }
    }
}
