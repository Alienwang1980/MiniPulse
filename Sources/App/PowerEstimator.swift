//
//  PowerEstimator.swift
//  MiniPulse
//
//  Estimates CPU/GPU power consumption based on utilization.
//  Used when IOReport Energy Model is not accessible (no private APIs).
//

import Foundation

struct PowerData {
    var cpuMw: Int = 0
    var gpuMw: Int = 0
    var ramMw: Int = 0
    var aneMw: Int = 0
    var pciMw: Int = 0
    var totalMw: Int = 0
}

/// Estimates CPU/GPU power consumption based on utilization and known M4 power characteristics
final class PowerEstimator {
    static let shared = PowerEstimator()

    // M4 Mac mini power characteristics
    // Mac mini M4 idle: ~8W total
    // CPU at 100%: adds ~15W above idle, GPU at 100%: adds ~5W above idle
    private let systemBaseMw: Int = 8000
    private let cpuPowerMaxMw: Int = 15000
    private let gpuPowerMaxMw: Int = 5000

    private var lastCpuUsage: Double = 0
    private var lastGpuUsage: Double = 0

    private init() {}

    func estimate(cpuUsagePercent: Double, gpuUsagePercent: Double) -> PowerData {
        let smoothCpu = lastCpuUsage * 0.7 + cpuUsagePercent * 0.3
        let smoothGpu = lastGpuUsage * 0.7 + gpuUsagePercent * 0.3
        lastCpuUsage = smoothCpu
        lastGpuUsage = smoothGpu

        let cpuDynW = (smoothCpu / 100.0) * Double(cpuPowerMaxMw) / 1000.0
        let gpuDynW = (smoothGpu / 100.0) * Double(gpuPowerMaxMw) / 1000.0
        let ramW = 1.5 + (smoothCpu / 100.0) * 0.5
        let aneW = 0.3
        let pciW = 1.0
        let totalWatt = Double(systemBaseMw) / 1000.0 + cpuDynW + gpuDynW + ramW + aneW + pciW

        return PowerData(
            cpuMw: Int(cpuDynW * 1000),
            gpuMw: Int(gpuDynW * 1000),
            ramMw: Int(ramW * 1000),
            aneMw: Int(aneW * 1000),
            pciMw: Int(pciW * 1000),
            totalMw: Int(totalWatt * 1000)
        )
    }
}