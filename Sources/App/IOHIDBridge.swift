//
//  IOHIDBridge.swift
//  MiniPulse
//
//  Apple Silicon temperature reading via IOHIDEventSystemClient (no root required)
//  Reference: Stats.app by exelban (MIT License)
//

import Foundation
import IOKit

// MARK: - Temperature Data

struct TemperatureData {
    var cpuDieTemp: Double? = nil
    var gpuDieTemp: Double? = nil
    var systemTemp: Double? = nil
    var allSensors: [String: Double] = [:]
}

// MARK: - IOHID Reader

final class IOHIDReader {
    static let shared = IOHIDReader()

    private init() {}

    /// Read temperature sensors via IOHIDEventSystemClient
    func readTemperatures() -> TemperatureData {
        // Apple Silicon temperature sensors use page=0xff00, usage=0x0005
        // Event type = kIOHIDEventTypeTemperature = 15
        return readHIDTemperature(page: 0xff00, usage: 0x0005, eventType: 15)
    }

    private func readHIDTemperature(page: Int32, usage: Int32, eventType: Int32) -> TemperatureData {
        guard let system = IOHIDEventSystemClientCreate(kCFAllocatorDefault) else {
            return TemperatureData()
        }

        let matching: [String: Any] = [
            "PrimaryUsagePage": page,
            "PrimaryUsage": usage
        ]
        IOHIDEventSystemClientSetMatching(system, matching as CFDictionary)

        guard let services = IOHIDEventSystemClientCopyServices(system) else {
            return TemperatureData()
        }

        var result = TemperatureData()
        let count = CFArrayGetCount(services)

        for i in 0..<count {
            guard let service = CFArrayGetValueAtIndex(services, i) else { continue }
            let serviceRef = unsafeBitCast(service, to: IOHIDServiceClientRef.self)

            // Get sensor name/product
            let nameRef = IOHIDServiceClientCopyProperty(serviceRef, "Product" as CFString)
            guard let name = nameRef as? String else { continue }

            // Get temperature event
            guard let event = IOHIDServiceClientCopyEvent(serviceRef, Int64(eventType), 0, 0) else {
                continue
            }

            // Get temperature value
            let field = IOHIDEventFieldBaseFunc(eventType)
            let value = IOHIDEventGetFloatValue(event, field)

            // Accept values in range 0-300 (Stats.app uses this range for Apple Silicon)
            guard value >= 0 && value <= 300 else { continue }

            result.allSensors[name] = value

            // Categorize by sensor name — Mac mini M4 sensor naming
            let lowerName = name.lowercased()
            // PMU tcal[N] = calibration/reference sensor, highest accuracy on Mac mini M4
            if lowerName.contains("tcal") {
                result.cpuDieTemp = max(result.cpuDieTemp ?? 0, value)
            } else if lowerName.contains("tdie") {
                // PMU tdie[N] = CPU die temperature
                result.cpuDieTemp = max(result.cpuDieTemp ?? 0, value)
            } else if lowerName.contains("pmu tdev") || lowerName.contains("tdev") {
                // PMU tdev[N] = thermal zone sensor
                result.cpuDieTemp = max(result.cpuDieTemp ?? 0, value)
            } else if lowerName.contains("pacc") || lowerName.contains("eacc") || lowerName.contains("cpu") {
                result.cpuDieTemp = max(result.cpuDieTemp ?? 0, value)
            } else if lowerName.contains("gpu") {
                result.gpuDieTemp = max(result.gpuDieTemp ?? 0, value)
            } else if lowerName.contains("nand") || lowerName.contains("disk") || lowerName.contains("ssd") {
                // NAND/disk = SSD temperature on Mac mini M4
                result.gpuDieTemp = max(result.gpuDieTemp ?? 0, value)
            } else if lowerName.contains("soc") || lowerName.contains("memory") {
                result.systemTemp = max(result.systemTemp ?? 0, value)
            }
        }

        // CFRelease not needed for these types - Core Foundation auto-manages them

        // If no categorized sensor found, use max from all available
        if result.cpuDieTemp == nil && result.gpuDieTemp == nil && result.systemTemp == nil {
            if let maxVal = result.allSensors.values.max() {
                result.cpuDieTemp = maxVal
            }
        }

        return result
    }
}
