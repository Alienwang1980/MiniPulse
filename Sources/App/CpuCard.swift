import SwiftUI

// MARK: - CPU Card

struct CpuCard: View {
    let cpu: CpuInfo
    let cpuTempC: Double?
    @State private var displayed: Double = 0
    @State private var displayedTemp: Double = 0

    private var theme: AppTheme { AppTheme.shared }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card header
            HStack(spacing: 9.6) {
                Image(systemName: "cpu")
                    .font(PixelFont.eightBit(size: 16.8))                    .foregroundColor(theme.cpuAccent)
                    .frame(width: 40.3, height: 40.3)
                    .background(theme.cpuAccent.opacity(0.20))
                    .cornerRadius(9.6)
                VStack(alignment: .leading, spacing: 1.2) {
                    Text("CPU")
                        .font(PixelFont.eightBit(size: 14.4, weight: Font.Weight.semibold))                        .foregroundColor(theme.text)
                    Text("\(cpu.physical) 核 / \(cpu.logical) 线程")
                        .font(PixelFont.eightBit(size: 12))                        .foregroundColor(theme.muted)
                }
                Spacer()
                // Temperature in header (same size as utilization %)
                if let temp = cpuTempC {
                    HStack(spacing: 4.8) {
                        Image(systemName: "thermometer.medium")
                            .font(PixelFont.eightBit(size: 19.2))                            .foregroundColor(theme.cpuAccent)
                        Text(String(format: "%.0f°C", displayedTemp))
                            .font(PixelFont.eightBit(size: 26, weight: Font.Weight.bold, design: .rounded))                            .foregroundColor(theme.cpuAccent)
                            .contentTransition(.numericText())
                    }
                }
            }

            // Big stat
            ZStack(alignment: .leading) {
                if theme.isEightBit {
                    HeroPatternBackground(pattern: CardHeroPattern.cpu, color: theme.cpuAccent, opacity: 0.12)
                }
                HStack(alignment: .lastTextBaseline, spacing: 2.4) {
                    Text("\(Int(displayed))")
                        .font(PixelFont.eightBit(size: 70, weight: Font.Weight.bold, design: .rounded))
                        .foregroundColor(theme.cpuAccent)
                        .contentTransition(.numericText())
                    Text("%")
                        .font(PixelFont.eightBit(size: 28.8, weight: Font.Weight.medium))
                        .foregroundColor(theme.muted)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.cpuCardBg)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(colors: [theme.cpuAccent, theme.cpuGrad2], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * displayed / 120, height: 6)
                }
            }
            .frame(height: 6)

            // Per-core grid — 每行 coreCount/2 列，宽度填满卡片
            if !cpu.perCore.isEmpty {
                let cols = max(1, cpu.perCore.count / 2)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4.8), count: cols), spacing: 4.8) {
                    ForEach(0..<cpu.perCore.count, id: \.self) { i in
                        CoreBarCell(index: i, percent: cpu.perCore[i])
                    }
                }
            }

            // Time breakdown
            Text("时间分解")
                .font(PixelFont.eightBit(size: 10.8, weight: Font.Weight.semibold))                .foregroundColor(theme.muted)
                .textCase(.uppercase)
                .padding(.top, 4.8)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2.4) {
                    HStack(spacing: 4.8) {
                        Text("User")
                            .font(PixelFont.eightBit(size: 12, weight: Font.Weight.medium))                            .foregroundColor(theme.muted)
                        Text(String(format: "%.1f%%", cpu.timesUser))
                            .font(PixelFont.eightBit(size: 12, weight: Font.Weight.bold, design: .monospaced))                            .foregroundColor(theme.accent)
                    }
                    HStack(spacing: 4.8) {
                        Text("System")
                            .font(PixelFont.eightBit(size: 12, weight: Font.Weight.medium))                            .foregroundColor(theme.muted)
                        Text(String(format: "%.1f%%", cpu.timesSystem))
                            .font(PixelFont.eightBit(size: 12, weight: Font.Weight.bold, design: .monospaced))                            .foregroundColor(theme.orange)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2.4) {
                    HStack(spacing: 4.8) {
                        Text("频率")
                            .font(PixelFont.eightBit(size: 12, weight: Font.Weight.medium))                            .foregroundColor(theme.muted)
                        Text(String(format: "%.2f GHz", cpu.freqCurrent))
                            .font(PixelFont.eightBit(size: 12, weight: Font.Weight.bold, design: .monospaced))                            .foregroundColor(theme.accent2)
                    }
                    HStack(spacing: 4.8) {
                        Text("空闲")
                            .font(PixelFont.eightBit(size: 12, weight: Font.Weight.medium))                            .foregroundColor(theme.muted)
                        Text(String(format: "%.1f%%", cpu.timesIdle))
                            .font(PixelFont.eightBit(size: 12, weight: Font.Weight.bold, design: .monospaced))                            .foregroundColor(theme.green)
                    }
                }
            }
        }
        .padding(19.2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isEightBit ? theme.cpuCardBg : theme.card)
        .cornerRadius(14.4)
        .onAppear {
            displayed = cpu.percent
            displayedTemp = cpuTempC ?? 0
        }
        .onChange(of: cpu.percent) { _, newVal in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { displayed = newVal }
        }
        .onChange(of: cpuTempC) { _, newVal in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { displayedTemp = newVal ?? 0 }
        }
    }
}

// MARK: - Core Bar Cell

struct CoreBarCell: View {
    let index: Int
    let percent: Double
    @State private var displayed: Double = 0

    private var theme: AppTheme { AppTheme.shared }

    var body: some View {
        VStack(spacing: 2.4) {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.cpuCardBg)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor)
                        .frame(height: geo.size.height * displayed / 120)
                }
            }
            .frame(height: 33.6)
            Text("\(index)")
                .font(PixelFont.eightBit(size: 9.6, weight: Font.Weight.bold))                .foregroundColor(theme.muted)
        }
        .onAppear { displayed = percent }
        .onChange(of: percent) { _, newVal in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { displayed = newVal }
        }
    }

    var barColor: LinearGradient {
        if percent > 80 {
            return LinearGradient(colors: [theme.red, theme.cpuRed], startPoint: .bottom, endPoint: .top)
        } else if percent > 50 {
            return LinearGradient(colors: [theme.yellow, theme.orange], startPoint: .bottom, endPoint: .top)
        } else {
            return LinearGradient(colors: [theme.cpuAccent, theme.cpuLow], startPoint: .bottom, endPoint: .top)
        }
    }
}