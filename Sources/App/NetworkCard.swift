import SwiftUI

// MARK: - Network Card

struct NetworkCard: View {
    let net: NetworkInfo
    let ips: [NetworkInterface]
    @State private var displayedRecv: Double = 0
    @State private var displayedSent: Double = 0

    private var activeIfaces: [String] {
        return Array(net.knownIfaceNames).sorted()
    }

    private var theme: AppTheme { AppTheme.shared }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9.6) {
                Image(systemName: "network")
                    .font(.system(size: 16.8))
                    .foregroundColor(theme.netAccent)
                    .frame(width: 40.3, height: 40.3)
                    .background(theme.netAccent.opacity(0.20))
                    .cornerRadius(9.6)
                VStack(alignment: .leading, spacing: 1.2) {
                    Text("网络 I/O")
                        .font(.system(size: 14.4, weight: .semibold))
                        .foregroundColor(theme.text)
                    Text("实时速度")
                        .font(.system(size: 12))
                        .foregroundColor(theme.muted)
                }
                Spacer()
            }

            // Real-time speed
            HStack(spacing: 19.2) {
                VStack(alignment: .leading, spacing: 2.4) {
                    Text("↓ 接收")
                        .font(.system(size: 10.8))
                        .foregroundColor(theme.muted)
                    HStack(alignment: .lastTextBaseline, spacing: 2.4) {
                        Text(formatSpeed(displayedRecv).value)
                            .font(.system(size: 26.4, weight: .bold, design: .monospaced))
                            .foregroundColor(theme.green)
                            .contentTransition(.numericText())
                        Text(formatSpeed(displayedRecv).unit)
                            .font(.system(size: 12))
                            .foregroundColor(theme.muted)
                    }
                }
                VStack(alignment: .leading, spacing: 2.4) {
                    Text("↑ 发送")
                        .font(.system(size: 10.8))
                        .foregroundColor(theme.muted)
                    HStack(alignment: .lastTextBaseline, spacing: 2.4) {
                        Text(formatSpeed(displayedSent).value)
                            .font(.system(size: 26.4, weight: .bold, design: .monospaced))
                            .foregroundColor(theme.accent)
                            .contentTransition(.numericText())
                        Text(formatSpeed(displayedSent).unit)
                            .font(.system(size: 12))
                            .foregroundColor(theme.muted)
                    }
                }
                Spacer()
            }

            Divider().background(theme.isEightBit ? theme.netAccent.opacity(0.20) : theme.border)

            // Per-interface with IP
            ForEach(activeIfaces, id: \.self) { iface in
                if let stats = net.perIface[iface] {
                    // Find IP for this interface
                    let ifaceIP = ips.first { $0.iface == iface }?.ip ?? ""
                    HStack {
                        VStack(alignment: .leading, spacing: 2.4) {
                            Text(stats.label)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(theme.muted)
                            if !ifaceIP.isEmpty {
                                Text(ifaceIP)
                                    .font(.system(size: 10.8, weight: .bold, design: .monospaced))
                                    .foregroundColor(theme.accent2)
                            }
                        }
                        Spacer()
                        Text("↓ \(formatSpeed(stats.recvMBs).value) \(formatSpeed(stats.recvMBs).unit)")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(theme.green)
                        Text("↑ \(formatSpeed(stats.sentMBs).value) \(formatSpeed(stats.sentMBs).unit)")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(theme.accent)
                    }
                }
            }

            // Total
            Divider().background(theme.isEightBit ? theme.netAccent.opacity(0.20) : theme.border)
            HStack {
                Text("总发送")
                    .font(.system(size: 13.2, weight: .medium))
                    .foregroundColor(theme.muted)
                Spacer()
                Text(formatBytes(net.totalSentMB * 1024 * 1024))
                    .font(.system(size: 13.2, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.accent2)
            }
            HStack {
                Text("总接收")
                    .font(.system(size: 13.2, weight: .medium))
                    .foregroundColor(theme.muted)
                Spacer()
                Text(formatBytes(net.totalRecvMB * 1024 * 1024))
                    .font(.system(size: 13.2, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.green)
            }
        }
        .padding(19.2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isEightBit ? theme.netCardBg : theme.card)
        .cornerRadius(14.4)
        .onAppear {
            displayedRecv = net.recvMBs
            displayedSent = net.sentMBs
        }
        .onChange(of: net.recvMBs) { _, newVal in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { displayedRecv = newVal }
        }
        .onChange(of: net.sentMBs) { _, newVal in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { displayedSent = newVal }
        }
    }

    func formatSpeed(_ mbS: Double) -> (value: String, unit: String) {
        if mbS >= 1 {
            return (String(format: "%.1f", mbS), "MB/s")
        } else {
            return (String(format: "%.0f", mbS * 1024), "KB/s")
        }
    }

    func formatBytes(_ bytes: Double) -> String {
        if bytes < 1024 * 1024 {
            return String(format: "%.1f MB", bytes / 1024)
        } else {
            return String(format: "%.2f GB", bytes / 1024 / 1024)
        }
    }
}
