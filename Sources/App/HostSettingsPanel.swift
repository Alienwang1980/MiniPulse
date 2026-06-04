import SwiftUI

// MARK: - Host Settings Panel (LAN management)

struct HostSettingsPanel: View {
    @Binding var isPresented: Bool
    @State private var hostManager = HostManager.shared
    @State private var refreshCount = 0

    private var theme: AppTheme { AppTheme.shared }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("局域网管理")
                    .font(PixelFont.eightBit(size: 18, weight: Font.Weight.bold))
                    .foregroundColor(theme.text)
                Spacer()
            }
            .padding(24)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ── Local host section ──────────────────────────────────
                    localHostSection

                    // ── Remote hosts ────────────────────────────────────────
                    ForEach(hostManager.hosts.filter { !$0.isLocal }) { host in
                        remoteHostSection(host)
                    }

                    if hostManager.hosts.filter({ !$0.isLocal }).isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24))
                                .foregroundColor(theme.muted.opacity(0.5))
                            Text("未发现局域网中的其他 MiniPulse")
                                .font(PixelFont.eightBit(size: 12))
                                .foregroundColor(theme.muted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    }
                }
                .id(refreshCount)
                .padding(24)
            }

            // Footer
            HStack {
                Button(action: refreshHosts) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11))
                        Text("刷新")
                            .font(PixelFont.eightBit(size: 11))
                    }
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
        }
        .frame(width: 500, height: 500)
        .background(theme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 14.4)
                .stroke(theme.accent.opacity(0.10), lineWidth: 1)
        )
    }

    // MARK: - Local host section

    private var localHostSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "desktopcomputer")
                    .foregroundColor(theme.accent)
                Text("本机")
                    .font(PixelFont.eightBit(size: 14, weight: Font.Weight.semibold))
                    .foregroundColor(theme.text)
                Spacer()
            }

            // Broadcast toggle
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(hostManager.broadcastingEnabled ? theme.green : theme.muted)
                Text("局域网广播")
                    .font(PixelFont.eightBit(size: 13))
                    .foregroundColor(theme.text)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { hostManager.broadcastingEnabled },
                    set: { hostManager.broadcastingEnabled = $0 }
                ))
                .toggleStyle(.switch)
                .controlSize(.small)
            }
            .padding(.vertical, 4)

            Divider()

            // Card toggles for local host
            Text("卡片显示")
                .font(PixelFont.eightBit(size: 12))
                .foregroundColor(theme.muted)
                .textCase(.uppercase)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(CardType.allCases) { cardType in
                    cardToggle(cardType: cardType, hostId: SystemMonitor.localHostId)
                }
            }
        }
        .padding(16)
        .background(theme.card)
        .cornerRadius(12)
    }

    // MARK: - Remote host section

    private func remoteHostSection(_ host: Host) -> some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 12) {
                // Card toggles
                Text("卡片显示")
                    .font(PixelFont.eightBit(size: 12))
                    .foregroundColor(theme.muted)
                    .textCase(.uppercase)
                    .padding(.top, 4)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(CardType.allCases) { cardType in
                        cardToggle(cardType: cardType, hostId: host.id)
                    }
                }

                // Forget button
                Button(role: .destructive) {
                    hostManager.forgetHost(host.id)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("忘记这台主机")
                    }
                    .font(PixelFont.eightBit(size: 11))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.leading, 8)
            .padding(.bottom, 8)
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(host.isOnline ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(host.name)
                    .font(PixelFont.eightBit(size: 14, weight: Font.Weight.semibold))
                    .foregroundColor(theme.text)
                Spacer()
                Text(host.machineModel)
                    .font(PixelFont.eightBit(size: 11))
                    .foregroundColor(theme.muted)
            }
        }
        .padding(16)
        .background(theme.card)
        .cornerRadius(12)
        .accentColor(theme.accent)
    }

    // MARK: - Card toggle

    private func cardToggle(cardType: CardType, hostId: String) -> some View {
        HStack(spacing: 4) {
            Toggle("", isOn: Binding(
                get: { hostManager.isCardVisible(cardType, for: hostId) },
                set: { hostManager.setCardVisible($0, for: cardType, hostId: hostId) }
            ))
            .toggleStyle(.switch)
            .controlSize(.mini)
            .scaleEffect(0.8)

            Text(cardType.displayName)
                .font(PixelFont.eightBit(size: 10))
                .foregroundColor(theme.text)
                .lineLimit(1)
        }
    }

    // MARK: - Refresh

    private func refreshHosts() {
        refreshCount += 1
        NotificationCenter.default.post(name: Notification.Name("com.hermes.minipulse.hostListChanged"), object: nil)
    }
}
