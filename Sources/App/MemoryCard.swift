import SwiftUI

// MARK: - Memory Card

struct MemoryCard: View {
    let mem: MemoryInfo
    @State private var displayed: Double = 0
    private var theme: AppTheme { AppTheme.shared }


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9.6) {
                Image(systemName: "memorychip")
                    .font(.system(size: 16.8))
                    .foregroundColor(theme.memAccent)
                    .frame(width: 40.3, height: 40.3)
                    .background(theme.memAccent.opacity(0.20))
                    .cornerRadius(9.6)
                VStack(alignment: .leading, spacing: 1.2) {
                    Text("内存 (RAM)")
                        .font(.system(size: 14.4, weight: .semibold))
                        .foregroundColor(theme.text)
                    Text(String(format: "%.1f GB", mem.totalGB))
                        .font(.system(size: 12))
                        .foregroundColor(theme.muted)
                }
                Spacer()
            }

            HStack(alignment: .lastTextBaseline, spacing: 2.4) {
                Text("\(Int(displayed))")
                    .font(.system(size: 57.6, weight: .bold, design: .rounded))
                    .foregroundColor(theme.memAccent)
                    .contentTransition(.numericText())
                Text("%")
                    .font(.system(size: 28.8, weight: .medium))
                    .foregroundColor(theme.muted)
            }

            Text(String(format: "%.1f / %.1f GB", mem.usedGB, mem.totalGB))
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(theme.muted)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.memCardBg)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(colors: [theme.memAccent, theme.memGrad2], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * displayed / 120, height: 6)
                }
            }
            .frame(height: 6)

            // Details
            VStack(spacing: 4.8) {
                DetailRow(label: "已用", value: String(format: "%.1f GB", mem.usedGB), color: theme.accent3)
                DetailRow(label: "可用", value: String(format: "%.1f GB", mem.availableGB), color: theme.green)
            }

            // Swap
            Text("Swap")
                .font(.system(size: 10.8, weight: .semibold))
                .foregroundColor(theme.muted)
                .textCase(.uppercase)
                .padding(.top, 4.8)

            HStack(spacing: 7.2) {
                Text(String(format: "%.1f GB", mem.swapUsedGB))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.orange)
                Text("/")
                    .foregroundColor(theme.muted)
                Text(String(format: "%.1f GB", mem.swapTotalGB))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(theme.muted)
                Spacer()
                Text(String(format: "%.0f%%", mem.swapPercent))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(theme.orange)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.memCardBg)
                        .frame(height: 4.8)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(colors: [theme.swapGrad1, theme.swapGrad2], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * mem.swapPercent / 120, height: 4.8)
                }
            }
            .frame(height: 4.8)
        }
        .padding(19.2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isEightBit ? theme.memCardBg : theme.card)
        .cornerRadius(14.4)
        .onAppear { displayed = mem.percent }
        .onChange(of: mem.percent) { _, newVal in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { displayed = newVal }
        }
    }
}