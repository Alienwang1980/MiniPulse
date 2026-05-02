import SwiftUI

// MARK: - Top Memory Processes Card

struct TopMemCard: View {
    let topMem: [ProcessEntry]
    private var theme: AppTheme { AppTheme.shared }


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9.6) {
                Group {
                    if theme.isEightBit {
                        Image("topMem")
                            .resizable()
                            .scaledToFit().frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "memorychip.fill")
                    }
                }
                    .font(PixelFont.eightBit(size: 16.8))                    .foregroundColor(theme.topAccent)
                    .frame(width: 37.4, height: 37.4)
                    .background(theme.topAccent.opacity(0.20))
                    .cornerRadius(7.2)
                Text("Top 内存进程")
                    .font(PixelFont.eightBit(size: 15.6, weight: Font.Weight.semibold))                    .foregroundColor(theme.text)
                Spacer()
            }

            VStack(spacing: 4.8) {
                ForEach(topMem.prefix(6)) { proc in
                    HStack(spacing: 9.6) {
                        Text(proc.name)
                            .font(PixelFont.eightBit(size: 13.2))
                            .foregroundColor(theme.text)
                            .lineLimit(1)
                            .frame(maxWidth: 240, alignment: .leading)
                        Spacer()
                        Text(String(format: "%.0f MB", proc.memMB))
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
