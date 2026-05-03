import SwiftUI
import AppKit

// MARK: - Disk Card

struct DiskCard: View {
    let disks: [DiskInfo]
    let diskIO: DiskIOInfo
    let ssdTempC: Double?
    @State private var displayedTotal: Double = 0
    private var theme: AppTheme { AppTheme.shared }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9.6) {
                Group {
                    if theme.isEightBit {
                        Image("disk")
                            .resizable()
                            .scaledToFit().frame(width: 22, height: 22)
                    } else {
                        Image(systemName: "internaldrive")
                    }
                }
                    .font(PixelFont.eightBit(size: 16.8))                    .foregroundColor(theme.diskAccent)
                    .frame(width: 40.3, height: 40.3)
                    .background(theme.diskAccent.opacity(0.20))
                    .cornerRadius(9.6)
                VStack(alignment: .leading, spacing: 1.2) {
                    Text("磁盘存储")
                        .font(PixelFont.eightBit(size: 14.4, weight: Font.Weight.semibold))                        .foregroundColor(theme.text)
                    Text("实时吞吐量")
                        .font(PixelFont.eightBit(size: 12))                        .foregroundColor(theme.muted)
                }
                Spacer()
                // SSD temperature in header (large, like CPU card)
                if let ssd = ssdTempC, ssd > 0 {
                    HStack(spacing: 4.8) {
                        Image(systemName: "thermometer.medium")
                            .font(PixelFont.eightBit(size: 19.2))                            .foregroundColor(theme.diskAccent)
                        Text(String(format: "%.0f°C", ssd))
                            .font(PixelFont.eightBit(size: 36, weight: Font.Weight.bold, design: .rounded))                            .foregroundColor(theme.diskAccent)
                            .contentTransition(.numericText())
                    }
                }

            }

            // Real-time total disk throughput
            ZStack(alignment: .leading) {
                if theme.isEightBit {
                    HeroPatternBackground(pattern: CardHeroPattern.disk, color: theme.diskAccent, opacity: 0.12)
                }
                HStack(alignment: .lastTextBaseline, spacing: 2.4) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(PixelFont.eightBit(size: 19.2))
                        .foregroundColor(theme.diskAccent)
                    Text(String(format: "%.1f", displayedTotal))
                        .font(PixelFont.eightBit(size: 36, weight: Font.Weight.bold, design: .monospaced))
                        .foregroundColor(theme.text)
                        .contentTransition(.numericText())
                    Text("MB/s")
                        .font(PixelFont.eightBit(size: 12))
                        .foregroundColor(theme.muted)
                    Spacer()
                }
            }

            Divider().background(theme.isEightBit ? theme.diskAccent.opacity(0.20) : theme.border)

            // Each disk
            ForEach(disks) { disk in
                if disk.isMounted {
                    VStack(alignment: .leading, spacing: 4.8) {
                        HStack {
                            Image(systemName: "internaldrive.fill")
                                .font(PixelFont.eightBit(size: 14.4))                                .foregroundColor(theme.diskAccent)
                            Text(disk.name)
                                .font(PixelFont.eightBit(size: 14.4, weight: Font.Weight.semibold))                                .foregroundColor(theme.text)
                            Spacer()
                            Text(String(format: "%.0f%%", disk.percent))
                                .font(PixelFont.eightBit(size: 15.6, weight: Font.Weight.bold))                                .foregroundColor(diskColor(disk.percent))
                            Text(String(format: "%.0f GB free", disk.freeGB))
                                .font(PixelFont.eightBit(size: 12))                                .foregroundColor(theme.muted)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(theme.diskCardBg)
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(diskGradient(disk.percent))
                                    .frame(width: max(0, min(geo.size.width, geo.size.width * disk.percent / 100)), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                } else {
                    HStack {
                        Image(systemName: "eject")
                            .font(PixelFont.eightBit(size: 14.4))                            .foregroundColor(theme.muted)
                        Text(disk.name)
                            .font(PixelFont.eightBit(size: 14.4, weight: Font.Weight.semibold))                            .foregroundColor(theme.muted)
                        Spacer()
                        Text("未挂载")
                            .font(PixelFont.eightBit(size: 12))                            .foregroundColor(theme.muted)
                    }
                }
            }
        }
        .padding(19.2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isEightBit ? theme.diskCardBg : theme.card)
        .cornerRadius(14.4)
        .onAppear {
            displayedTotal = diskIO.totalMBs
        }
        .onChange(of: diskIO.totalMBs) { oldVal, newVal in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { displayedTotal = newVal }
        }
    }

    func diskColor(_ pct: Double) -> Color {
        if pct > 90 { return theme.red }
        if pct > 70 { return theme.yellow }
        return theme.green
    }

    func diskGradient(_ pct: Double) -> LinearGradient {
        if pct > 90 {
            return LinearGradient(colors: [theme.red, theme.diskRed], startPoint: .leading, endPoint: .trailing)
        } else if pct > 70 {
            return LinearGradient(colors: [theme.yellow, theme.orange], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [theme.diskGrad1, theme.diskGrad2], startPoint: .leading, endPoint: .trailing)
        }
    }
}
