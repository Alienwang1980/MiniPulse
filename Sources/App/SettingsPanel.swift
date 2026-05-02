import SwiftUI

// MARK: - Settings Panel

struct SettingsPanel: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("设置")
                    .font(PixelFont.eightBit(size: 18, weight: Font.Weight.bold))                    .foregroundColor(AppTheme.shared.text)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(PixelFont.eightBit(size: 20))                        .foregroundColor(AppTheme.shared.muted)
                }
                .buttonStyle(.plain)
            }
            .padding(24)

            Divider()

            // Theme section
            VStack(alignment: .leading, spacing: 16) {
                Text("主题")
                    .font(PixelFont.eightBit(size: 13, weight: Font.Weight.semibold))                    .foregroundColor(AppTheme.shared.muted)
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

            // Version
            HStack {
                Spacer()
                Text("MiniPulse v2.0")
                    .font(PixelFont.eightBit(size: 11))                    .foregroundColor(AppTheme.shared.muted.opacity(0.5))
                Spacer()
            }
            .padding(.bottom, 20)
        }
        .frame(width: 360, height: 280)
        .background(AppTheme.shared.surface)
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
                }
                Text(themeType.rawValue)
                    .font(PixelFont.eightBit(size: 9, weight: Font.Weight.bold))                    .foregroundColor(textOnPreview)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(textOnPreview.opacity(0.15))
                    .cornerRadius(4)
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
