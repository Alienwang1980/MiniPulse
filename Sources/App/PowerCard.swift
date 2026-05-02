import SwiftUI

// MARK: - Power/Thermal Card

struct PowerCard: View {
    let temps: TempInfo
    let battery: BatteryInfo?
    let isLaptop: Bool
    @State private var displayedCpu: Double = 0
    @State private var displayedGpu: Double = 0
    @State private var displayedTotal: Double = 0
    private var theme: AppTheme { AppTheme.shared }


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9.6) {
                Image(systemName: "bolt.fill")
                    .font(PixelFont.eightBit(size: 16.8))                    .foregroundColor(theme.batteryAccent)
                    .frame(width: 40.3, height: 40.3)
                    .background(theme.batteryAccent.opacity(0.20))
                    .cornerRadius(9.6)
                VStack(alignment: .leading, spacing: 1.2) {
                    Text("功率")
                        .font(PixelFont.eightBit(size: 14.4, weight: Font.Weight.semibold))                        .foregroundColor(theme.text)
                    Text(subtitleText)
                        .font(PixelFont.eightBit(size: 12))                        .foregroundColor(theme.muted)
                }
                Spacer()
            }

            // Total power in W
            ZStack(alignment: .leading) {
                if theme.isEightBit {
                    HeroPatternBackground(pattern: CardHeroPattern.power, color: theme.orange, opacity: 0.12)
                }
                HStack(alignment: .lastTextBaseline, spacing: 2.4) {
                    Text(String(format: "%.1f", displayedTotal))
                        .font(PixelFont.eightBit(size: 48, weight: Font.Weight.bold, design: .rounded))
                        .foregroundColor(theme.orange)
                        .contentTransition(.numericText())
                    Text("W")
                        .font(PixelFont.eightBit(size: 24, weight: Font.Weight.medium))                        .foregroundColor(theme.muted)
                    Spacer()
                    Text("总功耗")
                        .font(PixelFont.eightBit(size: 13.2))                        .foregroundColor(theme.muted)
                }
            }

            // Power breakdown in W
            VStack(spacing: 7.2) {
                HStack {
                    Text("CPU 功耗")
                        .font(PixelFont.eightBit(size: 13.2, weight: Font.Weight.medium))                        .foregroundColor(theme.muted)
                    Spacer()
                    Text(String(format: "%.2f W", displayedCpu / 1000.0))
                        .font(PixelFont.eightBit(size: 13.2, weight: Font.Weight.bold, design: .monospaced))                        .foregroundColor(theme.accent)
                }
                HStack {
                    Text("GPU 功耗")
                        .font(PixelFont.eightBit(size: 13.2, weight: Font.Weight.medium))                        .foregroundColor(theme.muted)
                    Spacer()
                    Text(String(format: "%.2f W", displayedGpu / 1000.0))
                        .font(PixelFont.eightBit(size: 13.2, weight: Font.Weight.bold, design: .monospaced))                        .foregroundColor(theme.accent2)
                }
                HStack {
                    Text("板载功耗")
                        .font(PixelFont.eightBit(size: 13.2, weight: Font.Weight.medium))                        .foregroundColor(theme.muted)
                    Spacer()
                    Text(String(format: "%.2f W", Double(temps.boardPowerMw) / 1000.0))
                        .font(PixelFont.eightBit(size: 13.2, weight: Font.Weight.bold, design: .monospaced))                        .foregroundColor(theme.muted)
                }
            }
        }
        .padding(19.2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isEightBit ? theme.powerCardBg : theme.card)
        .cornerRadius(14.4)
        .onAppear {
            displayedCpu = Double(temps.cpuPowerMw)
            displayedGpu = Double(temps.gpuPowerMw)
            displayedTotal = Double(temps.totalPowerMw) / 1000.0
        }
        .onChange(of: temps.cpuPowerMw) { _, newVal in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { displayedCpu = Double(newVal) }
        }
        .onChange(of: temps.gpuPowerMw) { _, newVal in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { displayedGpu = Double(newVal) }
        }
        .onChange(of: temps.totalPowerMw) { _, newVal in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { displayedTotal = Double(newVal) / 1000.0 }
        }
    }

    var subtitleText: String {
        if isLaptop {
            return battery?.onBattery == true ? "电池供电" : "电源已接通"
        } else {
            return "SOC 功耗"
        }
    }

    var thermalLabel: String {
        switch temps.thermalLevel {
        case 0: return "✅ 热压力正常"
        case 1: return "🌡️ 轻微压力"
        case 2: return "⚠️ 严重压力"
        case 3: return "🔴 危险"
        default: return "✅ 热压力正常"
        }
    }

    var thermalColor: Color {
        switch temps.thermalLevel {
        case 0: return theme.green
        case 1: return theme.yellow
        case 2: return theme.orange
        case 3: return theme.red
        default: return theme.green
        }
    }

    func tierColor(for i: Int) -> Color {
        switch i {
        case 0: return theme.green
        case 1: return theme.yellow
        case 2: return theme.orange
        case 3: return theme.red
        default: return theme.green
        }
    }
}