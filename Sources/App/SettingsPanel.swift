import SwiftUI

// MARK: - Settings Panel

struct SettingsPanel: View {
    @Binding var isPresented: Bool
    var monitor: SystemMonitor?

    @State private var debugOutput: String = ""
    @State private var showDebugSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("设置")
                    .font(PixelFont.eightBit(size: 18, weight: Font.Weight.bold))
                    .foregroundColor(AppTheme.shared.text)
                Spacer()
                // Debug button — triggers disk I/O diagnostic
                Button {
                    triggerDebugDump()
                } label: {
                    Text("调试")
                        .font(PixelFont.eightBit(size: 12))
                        .foregroundColor(AppTheme.shared.accent)
                }
                .buttonStyle(.plain)
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

            // Version
            HStack {
                Spacer()
                Text("MiniPulse v2.0")
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
        .sheet(isPresented: $showDebugSheet) {
            DebugOutputSheet(content: $debugOutput, isPresented: $showDebugSheet)
        }
    }

    private func triggerDebugDump() {
        guard let monitor = monitor else {
            debugOutput = "SystemMonitor not available"
            showDebugSheet = true
            return
        }
        debugOutput = monitor.dumpDebugInfo()
        showDebugSheet = true
    }
}

// MARK: - Debug Output Sheet

struct DebugOutputSheet: View {
    @Binding var content: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("调试信息")
                    .font(PixelFont.eightBit(size: 16, weight: Font.Weight.bold))
                    .foregroundColor(AppTheme.shared.text)
                Spacer()
                Button("复制") {
                    #if os(macOS)
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(content, forType: .string)
                    #endif
                }
                .font(PixelFont.eightBit(size: 12))
                Button("保存到桌面") {
                    saveToDesktop()
                }
                .font(PixelFont.eightBit(size: 12))
                Button("关闭") {
                    isPresented = false
                }
                .font(PixelFont.eightBit(size: 12))
            }
            .padding(16)
            .background(AppTheme.shared.card)

            Divider()

            ScrollView {
                Text(content)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(AppTheme.shared.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
            .background(AppTheme.shared.surface)
        }
        .frame(width: 700, height: 500)
    }

    private func saveToDesktop() {
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let dirURL = desktopURL.appendingPathComponent("MiniPulse")
        let fileURL = dirURL.appendingPathComponent("disk_io_debug.txt")
        do {
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString("保存失败: \(error.localizedDescription)\n\n内容:\n\(content)", forType: .string)
        }
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
