import SwiftUI

// MARK: - Top CPU Processes Card

struct TopCPUCard: View {
    let topCPU: [ProcessEntry]
    private var theme: AppTheme { AppTheme.shared }


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9.6) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16.8))
                    .foregroundColor(theme.topAccent)
                    .frame(width: 37.4, height: 37.4)
                    .background(theme.topAccent.opacity(0.20))
                    .cornerRadius(7.2)
                Text("Top CPU 进程")
                    .font(.system(size: 15.6, weight: .semibold))
                    .foregroundColor(theme.text)
                Spacer()
            }

            VStack(spacing: 4.8) {
                ForEach(topCPU.prefix(6)) { proc in
                    HStack(spacing: 9.6) {
                        Text(proc.name)
                            .font(.system(size: 13.2))
                            .foregroundColor(theme.text)
                            .lineLimit(1)
                            .frame(maxWidth: 216, alignment: .leading)
                        Text("\(proc.pid)")
                            .font(.system(size: 10.8, design: .monospaced))
                            .foregroundColor(theme.muted)
                            .frame(width: 43.2, alignment: .leading)
                        Spacer()
                        Text(String(format: "%.1f%%", proc.cpuPercent))
                            .font(.system(size: 13.2, weight: .bold, design: .monospaced))
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
