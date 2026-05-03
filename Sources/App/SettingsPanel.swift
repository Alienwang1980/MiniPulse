import SwiftUI

// MARK: - Settings Panel

struct SettingsPanel: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("设置")
                    .font(PixelFont.eightBit(size: 18, weight: Font.Weight.bold))
                    .foregroundColor(AppTheme.shared.text)
                Spacer()
            }
            .padding(24)

            Divider()

            // Theme section
            VStack(alignment: .leading, spacing: 16) {
                Text("主题")
                    .font(PixelFont.eightBit(size: 13, weight: Font.Weight.semibold))
                    .foregroundColor(AppTheme.shared.muted)
                    .textCase(.uppercase)

                HStack(spacing: 12) {
                    ForEach(ThemeType.allCases, id: \.self) { themeType in
                        ThemeButton(themeType: themeType) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                AppTheme.shared.themeType = themeType
                            }
                        }
                    }
                }
            }
            .padding(24)

            Spacer()

            // Footer
            HStack {
                Button(action: {
                    if let url = URL(string: "mailto:feedback@minipulse.app?subject=MiniPulse%20Feedback") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "envelope")
                        Text("Feedback")
                    }
                    .font(PixelFont.eightBit(size: 11))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Spacer()

                Button("完成") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            // Version
            HStack {
                Spacer()
                Text("► Made with ♥ by Alienwang")
                    .font(PixelFont.eightBit(size: 11))
                    .foregroundColor(AppTheme.shared.muted.opacity(0.5))
                Spacer()
            }
            .padding(.bottom, 20)
        }
        .frame(width: 480, height: 340)
        .background(AppTheme.shared.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 14.4)
                .stroke(AppTheme.shared.accent.opacity(0.10), lineWidth: 1)
        )
    }
}

// MARK: - Theme Button

struct ThemeButton: View {
    let themeType: ThemeType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    // Background gradient
                    RoundedRectangle(cornerRadius: 10)
                        .fill(themePreviewGradient)
                        .frame(height: 60)

                    // Selection ring
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            AppTheme.shared.themeType == themeType ? AppTheme.shared.accent : Color.clear,
                            lineWidth: AppTheme.shared.themeType == themeType ? 2 : 0
                        )

                    // Theme name
                    Text(themeType == .ocean ? "Ocean" : "8bit")
                        .font(themeType == .ocean ? Font.system(size: 14, weight: .bold, design: .default) : PixelFont.eightBit(size: 13, weight: Font.Weight.bold))
                        .foregroundColor(textOnPreview)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var themePreviewGradient: LinearGradient {
        switch themeType {
        case .ocean:
            return LinearGradient(
                colors: [Color(hex: "1a2537"), Color(hex: "2d4a6f")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .eightBit:
            return LinearGradient(
                colors: [Color(hex: "1A1512"), Color(hex: "2A2520")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var textOnPreview: Color {
        switch themeType {
        case .ocean: return .white.opacity(0.9)
        case .eightBit: return Color(hex: "FAB1A0")
        }
    }
}
