import SwiftUI

// MARK: - Top CPU Processes Card

struct TopCPUCard: View {
    let topCPU: [ProcessEntry]
    private var theme: AppTheme { AppTheme.shared }


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9.6) {
                CardIcon(isEightBit: theme.isEightBit, imageName: "topCpu", sfSymbol: "chart.bar.fill", color: theme.topAccent, trigger: topCPU, size: 37.4)
                Text("Top CPU 进程")
                    .font(PixelFont.eightBit(size: 15.6, weight: Font.Weight.semibold))                    .foregroundColor(theme.text)
                Spacer()
            }

            VStack(spacing: 4.8) {
                ForEach(topCPU.prefix(6)) { proc in
                    HStack(spacing: 9.6) {
                        Text(proc.shortName)
                            .font(PixelFont.eightBit(size: 13.2))
                            .foregroundColor(theme.text)
                            .lineLimit(1)
                            .frame(maxWidth: 240, alignment: .leading)
                        Spacer()
                        Text(String(format: "%.1f%%", proc.cpuPercent))
                            .font(PixelFont.eightBit(size: 13.2, weight: Font.Weight.bold, design: .monospaced))
                            .foregroundColor(theme.topAccent)
                    }
                }
            }
        }
        .padding(19.2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isEightBit ? theme.topCardBg : theme.card)
        .cornerRadius(14.4)
    }
}
