import SwiftUI
import IOKit.ps
import Foundation
import AppKit

// MARK: - Battery Card (only shown on laptops)

struct BatteryCard: View {
    let battery: BatteryInfo?
    var totalOperatingHours: Int = 0   // 电池累计运行时间（小时）
    @State private var displayedPercent: Int = 0
    @State private var displayedCharging: Bool = false
    @State private var displayedOnBattery: Bool = false
    @State private var displayedCycleCount: Int = 0
    @State private var displayedHealth: Int = 0
    @State private var displayedTemp: Double = 0.0
    @State private var displayedTimeRemaining: Int = -1
    @State private var displayedMaxCap: Int = 0
    @State private var displayedVoltage: Double = 0.0
    @State private var displayedTotalHours: Int = 0

    private var batteryIcon: String {
        let pct = displayedPercent
        if displayedCharging {
            return "battery.100.bolt"
        } else if pct > 75 {
            return "battery.100"
        } else if pct > 50 {
            return "battery.75"
        } else if pct > 25 {
            return "battery.50"
        } else {
            return "battery.25"
        }
    }

    private var statusText: String {
        if displayedCharging {
            return "电源已接通"
        } else if displayedOnBattery {
            return "电池供电"
        } else {
            return "已接通"
        }
    }

    private var timeRemainingText: String {
        if displayedTimeRemaining < 0 {
            return "--"
        } else if displayedTimeRemaining == -2 {
            return "交流电"
        } else if displayedTimeRemaining >= 60 {
            let h = displayedTimeRemaining / 60
            let m = displayedTimeRemaining % 60
            return "\(h)h \(m)m"
        } else {
            return "\(displayedTimeRemaining)m"
        }
    }

    private var healthColor: Color {
        if displayedHealth >= 80 { return theme.green }
        if displayedHealth >= 50 { return theme.yellow }
        return theme.red
    }

    private var percentColor: Color {
        if displayedPercent > 50 { return theme.green }
        if displayedPercent > 20 { return theme.yellow }
        return theme.red
    }

    /// Formats battery total operating hours into "39486h ≈ 4y 186d" style string.
    private func formattedBatteryRuntime(_ hours: Int) -> String {
        if hours <= 0 { return "--" }
        let y = hours / 8760       // 24*365
        let remainingAfterY = hours % 8760
        let d = remainingAfterY / 24
        if y > 0 {
            return "\(hours)h ≈ \(y)y \(d)d"
        } else if d > 0 {
            return "\(hours)h ≈ \(d)d"
        } else {
            return "\(hours)h"
        }
    }

    private var theme: AppTheme { AppTheme.shared }

    var body: some View {
        VStack(alignment: .leading, spacing: 14.4) {
            // Card header
            HStack(spacing: 9.6) {
                Group {
                    if theme.isEightBit {
                        Image("battery")
                            .resizable()
                            .scaledToFit().frame(width: 22, height: 22)
                    } else {
                        Image(systemName: batteryIcon)
                    }
                }
                    .font(.system(size: 16.8))
                    .foregroundColor(theme.green)
                    .frame(width: 40.3, height: 40.3)
                    .background(theme.green.opacity(0.20))
                    .cornerRadius(9.6)
                VStack(alignment: .leading, spacing: 1.2) {
                    Text("电池")
                        .font(.system(size: 14.4, weight: .semibold))
                        .foregroundColor(theme.text)
                    Text(statusText)
                        .font(.system(size: 12))
                        .foregroundColor(theme.muted)
                }
                Spacer()
                // Temperature in header (same size as CPU card)
                if displayedTemp > 0 {
                    HStack(spacing: 4.8) {
                        Image(systemName: "thermometer.medium")
                            .font(.system(size: 19.2))
                            .foregroundColor(theme.batteryAccent)
                        Text(String(format: "%.0f°C", displayedTemp))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(theme.batteryAccent)
                            .contentTransition(.numericText())
                    }
                }

            }

            if let bat = battery {
                // Main: large percent + gauge bar
                HStack(alignment: .lastTextBaseline, spacing: 2.4) {
                    Text("\(displayedPercent)")
                        .font(.system(size: 52.8, weight: .bold, design: .rounded))
                        .foregroundColor(percentColor)
                        .contentTransition(.numericText())
                    Text("%")
                        .font(.system(size: 26.4, weight: .medium))
                        .foregroundColor(theme.muted)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2.4) {
                        if displayedCharging {
                            Text("⚡ 充电中")
                                .font(.system(size: 13.2, weight: .bold))
                                .foregroundColor(theme.green)
                        } else if displayedOnBattery {
                            Text("🔋 使用中")
                                .font(.system(size: 13.2, weight: .bold))
                                .foregroundColor(theme.yellow)
                        }
                        if displayedTotalHours > 0 {
                            Text(formattedBatteryRuntime(displayedTotalHours))
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(theme.muted)
                        } else {
                            Text("--")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(theme.muted)
                        }
                    }
                }

                // Battery progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(theme.batteryCardBg)
                            .frame(height: 12)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(percentColor)
                            .frame(width: geo.size.width * CGFloat(displayedPercent) / 100.0, height: 10)
                            .shadow(color: percentColor.opacity(0.5), radius: 3)
                    }
                }
                .frame(height: 12)

                // Metric grid: 2 rows x 2 columns, clean and balanced
                VStack(spacing: 12) {
                    HStack(spacing: 0) {
                        BatteryMetric(label: "循环次数", value: "\(displayedCycleCount)", unit: " 次")
                        BatteryMetric(label: "健康度", value: displayedHealth >= 0 ? "\(displayedHealth)" : "--", unit: " %", valueColor: healthColor)
                    }
                    HStack(spacing: 0) {
                        BatteryMetric(label: "当前容量", value: displayedMaxCap > 0 ? "\(displayedMaxCap)" : "--", unit: " mAh")
                        BatteryMetric(label: "电压", value: displayedVoltage > 0 ? String(format: "%.2f", displayedVoltage) : "--", unit: " V")
                    }
                }
            } else {
                Text("无电池信息（台式机）")
                    .font(.system(size: 16.8))
                    .foregroundColor(theme.muted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            }
        }
        .padding(19.2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isEightBit ? theme.batteryCardBg : theme.card)
        .cornerRadius(14.4)
        .onAppear {
            if let bat = battery {
                displayedPercent = bat.percent
                displayedCharging = bat.charging
                displayedOnBattery = bat.onBattery
                displayedCycleCount = bat.cycleCount
                displayedHealth = bat.healthPercent
                displayedTemp = bat.temperature
                displayedTimeRemaining = bat.timeRemaining
                displayedMaxCap = bat.maxCapacity
                displayedVoltage = Double(bat.voltage) / 1000.0
                displayedTotalHours = bat.totalOperatingHours
            }
        }
        .onChange(of: battery?.percent) { _, newVal in
            if let v = newVal {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { displayedPercent = v }
            }
        }
        .onChange(of: battery?.charging) { _, newVal in
            if let v = newVal { displayedCharging = v }
        }
        .onChange(of: battery?.onBattery) { _, newVal in
            if let v = newVal { displayedOnBattery = v }
        }
        .onChange(of: battery?.cycleCount) { _, newVal in
            if let v = newVal { displayedCycleCount = v }
        }
        .onChange(of: battery?.healthPercent) { _, newVal in
            if let v = newVal { displayedHealth = v }
        }
        .onChange(of: battery?.temperature) { _, newVal in
            if let v = newVal { displayedTemp = v }
        }
        .onChange(of: battery?.maxCapacity) { _, newVal in
            if let v = newVal { displayedMaxCap = v }
        }
        .onChange(of: battery?.voltage) { _, newVal in
            if let v = newVal { displayedVoltage = Double(v) / 1000.0 }
        }
        .onChange(of: battery?.timeRemaining) { _, newVal in
            if let v = newVal { displayedTimeRemaining = v }
        }
        .onChange(of: battery?.totalOperatingHours) { _, newVal in
            if let v = newVal { displayedTotalHours = v }
        }
    }
}

// MARK: - Battery Metric Cell
struct BatteryMetric: View {
    let label: String
    let value: String
    let unit: String
    var valueColor: Color = .secondary

    var body: some View {
        VStack(alignment: .leading, spacing: 2.4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.shared.muted)
            HStack(alignment: .lastTextBaseline, spacing: 1.2) {
                Text(value)
                    .font(.system(size: 16.8, weight: .bold, design: .rounded))
                    .foregroundColor(valueColor)
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.shared.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
