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
    @Binding var showSettings: Bool
    @Binding var showEditOrder: Bool

    @State private var displayedCpu: Double = 0

    private var theme: AppTheme { AppTheme.shared }

    private var deviceIcon: String {
        sysInfo.isLaptop ? "laptopcomputer" : "desktopcomputer"
    }

    var body: some View {
        HStack(spacing: 16.8) {
            // Left: device icon (scaled 20% larger)
            Image(systemName: deviceIcon)
                .font(PixelFont.eightBit(size: 31.2))                .foregroundColor(theme.accent)
                .frame(width: 62.4, height: 62.4)
                .background(theme.accent.opacity(0.15))
                .cornerRadius(14.4)

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

            // Right: settings + edit buttons
            HStack(spacing: 12) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(PixelFont.eightBit(size: 16.8))                        .foregroundColor(theme.muted)
                }
                .buttonStyle(.plain)

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
        .onAppear { displayedCpu = cpu.percent }
        .onChange(of: cpu.percent) { _, newVal in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { displayedCpu = newVal }
        }
    }
}
