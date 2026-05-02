import SwiftUI
import Combine
import IOKit
import Darwin
import os.log

// MARK: - Feature Flags (Phase 1: minimal stable config)

/// Set to false to disable expensive data collections for stability testing
private let ENABLE_GPU_INFO        = true   // ioreg + system_profiler SPDisplaysDataType
private let ENABLE_BATTERY_INFO   = false  // IOServiceGetMatchingService (MacBook Pro: working, Mac mini: kIOReturnNotPermitted)
private let ENABLE_DISK_INFO      = true   // system_profiler SPStorageDataType + diskutil per volume (startup only)
private let ENABLE_USB_DEVICES    = false  // ioreg IOUSBHostDevice (startup + IOKit events) — DISABLED: causes resource leaks
private let ENABLE_BT_DEVICES     = false  // system_profiler SPBluetoothDataType (startup only) — DISABLED: stability
private let ENABLE_TOP_PROCESSES  = true   // ps command (background thread + manual refresh)
private let ENABLE_DISPLAY_INFO   = true   // system_profiler SPDisplaysDataType (startup only)
private let ENABLE_TEMPERATURES   = false  // DISABLED: IOHIDEventSystemClientCreate called every 5s causes resource leaks

/// Refresh interval: longer = less CPU overhead
private let REFRESH_INTERVAL: TimeInterval = 5.0

// MARK: - Extensions

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Data Models

struct SysInfo {
    var userName: String = ""        // e.g. "mini"
    var hostname: String = ""
    var osVersion: String = ""
    var hwModel: String = ""        // e.g. "Mac16,2"
    var machineModelName: String = "" // e.g. "Mac mini"
    var uptime: String = ""
    var ips: [NetworkInterface] = []
    var displayResolutions: [String] = []
    var gpuName: String = "Apple Silicon GPU"
    var gpuVRAM: Int = 0
    var isLaptop: Bool = false       // true if device has a battery
}

struct NetworkInterface: Identifiable, Hashable {
    let id = UUID()
    var iface: String
    var ip: String
    var label: String
}

struct CpuInfo: Equatable {
    var percent: Double = 0
    var perCore: [Double] = []
    var physical: Int = 0
    var logical: Int = 0
    var freqCurrent: Double = 0
    var freqMin: Double = 0
    var freqMax: Double = 0
    var timesUser: Double = 0
    var timesSystem: Double = 0
    var timesIdle: Double = 0
    var timesNice: Double = 0
}

struct MemoryInfo {
    var totalGB: Double = 0
    var usedGB: Double = 0
    var availableGB: Double = 0
    var freeGB: Double = 0
    var percent: Double = 0
    var swapTotalGB: Double = 0
    var swapUsedGB: Double = 0
    var swapPercent: Double = 0
}

struct GpuInfo: Equatable {
    var name: String = "Apple Silicon GPU"
    var vramMB: Int = 0
    var utilization: Int? = nil
    var chip: String? = nil
    var utilizationHistory: [Int] = []
}

struct TempInfo {
    var cpuPowerMw: Int = 0
    var gpuPowerMw: Int = 0
    var boardPowerMw: Int = 0   // RAM + ANE + PCI baseline (~2.8W)
    var totalPowerMw: Int = 0    // CPU + GPU + board total
    var cpuTempC: Double? = nil
    var gpuTempC: Double? = nil
    var ssdTempC: Double? = nil  // NAND/SSD temperature (Mac mini M4)
    var thermalPressure: String = "Nominal"
    var thermalLevel: Int = 0
}

struct BatteryInfo {
    var percent: Int = 0
    var charging: Bool = false
    var onBattery: Bool = false       // 是否使用电池供电
    var cycleCount: Int = 0
    var maxCapacity: Int = 0           // 当前最大容量 (mAh)
    var designCapacity: Int = 0       // 设计容量 (mAh)
    var healthPercent: Int = 0        // 健康度 (%)
    var voltage: Int = 0              // 当前电压 (mV)
    var temperature: Double = 0.0    // 温度 (℃)
    var timeRemaining: Int = -1       // 剩余时间（分钟），-1=计算中，-2=交流电
    var totalOperatingHours: Int = 0   // 电池累计运行时间（小时），从 LifetimeData.TotalOperatingTime 读取
}

struct DiskInfo: Identifiable, Hashable {
    let id = UUID()
    var name: String = ""
    var mountpoint: String = ""
    var totalGB: Double = 0
    var usedGB: Double = 0
    var freeGB: Double = 0
    var percent: Double = 0
    var isMounted: Bool = true
}

struct DiskIOInfo {
    var readMBs: Double = 0
    var writeMBs: Double = 0
    var totalReadMB: Double = 0
    var totalWriteMB: Double = 0
}

struct NetworkInfo {
    var totalSentMB: Double = 0
    var totalRecvMB: Double = 0
    var sentMBs: Double = 0
    var recvMBs: Double = 0
    var perIface: [String: IfaceStats] = [:]
    // Set of interface names that have been auto-detected (have an IP)
    var knownIfaceNames: Set<String> = []
    // Raw netstat output for diagnostics
    var netstatRaw: String = ""
}

struct IfaceStats: Hashable {
    var label: String = ""
    var sentMBs: Double = 0
    var recvMBs: Double = 0
}

struct ProcessEntry: Identifiable, Hashable {
    let id = UUID()
    var pid: Int
    var name: String
    var cpuPercent: Double = 0
    var memPercent: Double = 0
    var memMB: Double = 0
}

struct BluetoothDevice: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var status: String
    var type: String
}

struct UsbDevice: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var speed: String       // Display string: "USB4", "USB 3.2 Gen2", "USB 2.0", etc.

    /// Extracts numeric Gbps value from speed string for sorting.
    /// Higher = faster. USB4=40, USB 3.2 Gen2x2=20, USB 3.2 Gen2=10, USB 3.0=5, USB 2.0=2, USB 1.1=1.
    var speedGbps: Double {
        let s = speed
        if s.contains("USB4") { return 40 }
        if s.contains("3.2") {
            if s.contains("Gen2x2") || s.contains("20") { return 20 }
            if s.contains("Gen2") { return 10 }
            return 10
        }
        if s.contains("3.1") || s.contains("3.0") { return 5 }
        if s.contains("2.0") { return 2 }
        if s.contains("1.1") || s.contains("1.0") { return 1 }
        // Fallback: extract any number from string
        let numbers = s.filter { $0.isNumber || $0 == "." }.description
        return Double(numbers) ?? 0
    }
}

struct DeviceInfo {
    var bluetooth: [BluetoothDevice] = []
    var usb: [UsbDevice] = []
}

// MARK: - System Monitor

private let logger = Logger(subsystem: "ai.hermes.minipulse", category: "monitor")

class SystemMonitor: ObservableObject {
    @Published var sysInfo = SysInfo()
    @Published var cpu = CpuInfo()
    @Published var memory = MemoryInfo()
    @Published var gpu = GpuInfo()
    @Published var temps = TempInfo()
    @Published var battery: BatteryInfo? = nil
    @Published var disks: [DiskInfo] = []
    @Published var diskIO = DiskIOInfo()
    @Published var network = NetworkInfo()
    @Published var topCPU: [ProcessEntry] = []
    @Published var topMem: [ProcessEntry] = []
    @Published var devices = DeviceInfo()
    @Published var dataReady = false

    private var timer: DispatchSourceTimer?
    private let refreshQueue = DispatchQueue(label: "ai.hermes.minipulse.refresh", qos: .userInitiated)

    // Previous values for delta calculation
    private var prevNetSent: UInt64 = 0
    private var prevNetRecv: UInt64 = 0
    private var prevDiskReadBytes: UInt64 = 0
    private var prevDiskWriteBytes: UInt64 = 0
    // Track previously seen interfaces to avoid flicker (keep showing interface for 1+ cycle after it goes quiet)
    private var knownIfaceNames: Set<String> = []
    // Persisted previous byte counts for rate calculation (survives across refresh cycles)
    private var ifacBytes: [String: (sent: UInt64, recv: UInt64)] = [:]
    private var bootTime = Date()

    // Async disk I/O cache (updated by background timer)
    // Background timer samples every ~1s; main timer reads latest sample
    // iostat -I -d outputs MB directly as floating point
    private var lastDiskIO: (readMB: Double, writeMB: Double) = (0, 0)
    private let diskIOQueue = DispatchQueue(label: "ai.hermes.minipulse.diskio", qos: .utility)
    private var diskIOAccumulatorTimer: DispatchSourceTimer?

    // ifconfig cache (updated by background timer every 60s)
    // Network interface list rarely changes; timer loop reads cached result
    private var lastIfconfig: String = ""
    private let ifconfigQueue = DispatchQueue(label: "ai.hermes.minipulse.ifconfig", qos: .utility)
    private var ifconfigCacheTimer: DispatchSourceTimer?

    // GPU ioreg cache (1-second window to avoid excessive syscalls)
    private var ioregCache: (timestamp: Date, utilization: Int?) = (Date.distantPast, nil)

    // USB IOKit notification state
    private var usbNotificationPort: IONotificationPortRef?
    private var usbAddedIterator: io_iterator_t = 0
    private var usbRemovedIterator: io_iterator_t = 0

    // GPU utilization history (last 20 samples)
    private var gpuHistory: [Int] = Array(repeating: 0, count: 20)
    private var gpuHistIdx = 0

    // CPU tick history for delta calculation
    private var prevCpuTicks: [(user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)] = []
    // Overall CPU tick history (separate from per-core)
    private var prevOverallTicks: (user: UInt64, system: UInt64, idle: UInt64, nice: UInt64, total: UInt64) = (0, 0, 0, 0, 0)

    // Prevent concurrent execution of collectAllOnBackground
    private var isCollecting = false
    private let collectingLock = NSLock()
    // Cycle counter for periodic refresh of expensive collections (top processes, bluetooth, USB)
    private var topRefreshCounter = 0  // separate counter so Bluetooth doesn't depend on top reset
    private var btRefreshCounter = 0
    private var usbRefreshCounter = 0
    private let TOP_REFRESH_INTERVAL = 3  // refresh top processes every 3 cycles (~15s)
    private let BT_USB_REFRESH_INTERVAL = 6  // refresh bluetooth/USB every 6 cycles (~30s)

    init() {
        fputs("MiniPulse: init() called\n", stderr)
        // DO NOT call refresh() or any data collection here!
        // All startup data collection happens in start()
    }

    func start() {
        // Prevent double timer creation
        guard timer == nil else { return }
        fputs("MiniPulse: start() called\n", stderr)

        // Initial refresh after a longer delay to let SwiftUI finish its first render
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            fputs("MiniPulse: running startup collection\n", stderr)
            self.refreshBaseInfo()
            self.refresh()
            self.dataReady = true
        }

        // USB devices: collect once at startup + IOKit plug/unplug events
        collectUsbDevicesOnce()
        setupUsbNotifications()

        // Disk capacity: collect once at startup (not in timer loop)
        collectDiskInfoOnce()

        // Disk plug/unplug: listen for volume mount/unmount events via DiskArbitration
        setupDiskNotifications()

        // Display resolution: collect once at startup (not in timer loop)
        collectDisplayInfoOnce()

        // Bluetooth devices: collect once at startup (not in timer loop)
        collectBluetoothDevicesOnce()

        // Top processes: collect once at startup (not in timer loop)
        collectTopProcessesOnce()

        // GPU info (name/VRAM): collect once at startup (not in timer loop)
        collectGpuInfoOnce()

        // Start disk I/O background sampler (non-blocking, async)
        startDiskIOAccumulator()

        // Start ifconfig cache (refreshes every 60s, non-blocking)
        startIfconfigCache()

        // Start timer
        let queue = DispatchQueue(label: "ai.hermes.minipulse.timer", qos: .userInitiated)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now() + 5, repeating: 5, leeway: .milliseconds(200))
        timer?.setEventHandler { [weak self] in
            fputs("MiniPulse: timer fired!\n", stderr)
            self?.refresh()
        }
        timer?.resume()
        fputs("MiniPulse: timer started\n", stderr)
    }

    // MARK: - Async Disk I/O Accumulator (runs in background, non-blocking)

    private func startDiskIOAccumulator() {
        // Prevent double timer creation
        guard diskIOAccumulatorTimer == nil else { return }
        diskIOAccumulatorTimer = DispatchSource.makeTimerSource(queue: diskIOQueue)
        diskIOAccumulatorTimer?.schedule(deadline: .now(), repeating: REFRESH_INTERVAL)
        diskIOAccumulatorTimer?.setEventHandler { [weak self] in
            self?.sampleDiskIO()
        }
        diskIOAccumulatorTimer?.resume()
    }

    private func stopDiskIOAccumulator() {
        diskIOAccumulatorTimer?.cancel()
        diskIOAccumulatorTimer = nil
    }

    private func sampleDiskIO() {
        // iostat -d reports per-second throughput (MB/s) per disk for the last sampling interval.
        // macOS iostat doesn't separate read vs write, so we apply a fixed ratio:
        //   - When disk is active: 70% read, 30% write (typical consumer SSD workload)
        //   - When idle (MB/s < 0.1): both read and write are 0
        let result = run("/usr/sbin/iostat", args: ["-d", "-c", "1"], timeout: 4)
        var totalMB: Double = 0
        for line in result.components(separatedBy: "\n") {
            let cols = line.split(separator: " ", omittingEmptySubsequences: true)
            guard cols.count >= 3 else { continue }
            let firstCol = String(cols[0])
            guard !firstCol.hasPrefix("disk") && firstCol != "KB/t" else { continue }
            guard let _ = Double(firstCol) else { continue }
            guard let mbps = Double(cols[2]) else { continue }
            totalMB += mbps
        }
        let combinedMBs = totalMB
        let writeRatio: Double = combinedMBs > 0.1 ? 0.30 : 0.0
        let writeMB = combinedMBs * writeRatio
        let readMB = combinedMBs - writeMB
        lastDiskIO = (readMB, writeMB)
    }

    // MARK: - ifconfig Cache (updated by background timer every 60s)

    private func startIfconfigCache() {
        guard ifconfigCacheTimer == nil else { return }
        // Prime the cache immediately (synchronous, fast ~2ms)
        sampleIfconfig()
        // Refresh every 60s (first fire is at 60s from now)
        ifconfigCacheTimer = DispatchSource.makeTimerSource(queue: ifconfigQueue)
        ifconfigCacheTimer?.schedule(deadline: .now() + 60, repeating: 60, leeway: .seconds(1))
        ifconfigCacheTimer?.setEventHandler { [weak self] in
            self?.sampleIfconfig()
        }
        ifconfigCacheTimer?.resume()
    }

    private func stopIfconfigCache() {
        ifconfigCacheTimer?.cancel()
        ifconfigCacheTimer = nil
    }

    private func sampleIfconfig() {
        let result = run("/sbin/ifconfig", args: [], timeout: 2)
        lastIfconfig = result
    }

    func stop() {
        timer?.cancel()
        timer = nil
        stopDiskIOAccumulator()
        stopIfconfigCache()
        // Release USB IOKit iterators before destroying the notification port
        if usbAddedIterator != 0 {
            IOObjectRelease(usbAddedIterator)
            usbAddedIterator = 0
        }
        if usbRemovedIterator != 0 {
            IOObjectRelease(usbRemovedIterator)
            usbRemovedIterator = 0
        }
        usbNotificationPort.map { IONotificationPortDestroy($0) }
        usbNotificationPort = nil
    }

    // MARK: - Battery Collection (IOKit)
    private func collectBatteryInfoViaIOKit() -> BatteryInfo? {
        var batteryInfo: BatteryInfo?

        let matchingDict = IOServiceMatching("AppleSmartBattery")
        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator)

        guard result == KERN_SUCCESS else { return nil }
        defer { IOObjectRelease(iterator) }

        let service = IOIteratorNext(iterator)
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }

        var props: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(service, &props, kCFAllocatorDefault, 0) == KERN_SUCCESS,
              let dict = props?.takeRetainedValue() as? [String: Any] else {
            return nil
        }

        let currentCapacity = dict["CurrentCapacity"] as? Int ?? 0
        let maxCapacity = dict["MaxCapacity"] as? Int ?? 0
        let designCapacity = dict["DesignCapacity"] as? Int ?? 0
        let cycleCount = dict["CycleCount"] as? Int ?? 0
        let voltage = dict["Voltage"] as? Int ?? 0
        let temperature = dict["Temperature"] as? Int ?? 0  // deciKelvin (≈ 2970 = 27°C)
        let isCharging = dict["IsCharging"] as? Bool ?? false
        let externalConnected = dict["ExternalConnected"] as? Bool ?? false
        let timeRemaining = dict["TimeRemaining"] as? Int ?? -1

        // BatteryInstalled: if false, battery data is unreliable
        let batteryInstalled = dict["BatteryInstalled"] as? Bool ?? false
        guard batteryInstalled else { return nil }

        // AppleRaw* fields carry the real mAh values (unlike MaxCapacity which is often just 100 = percentage)
        let appleRawMaxCapacity = dict["AppleRawMaxCapacity"] as? Int ?? 0
        let appleRawCurrentCapacity = dict["AppleRawCurrentCapacity"] as? Int ?? 0
        let stateOfCharge = dict["StateOfCharge"] as? Int ?? 0

        // Percent: CurrentCapacity is 0-100 — this is the fuel-gauge percentage, most reliable
        // AppleRawCurrentCapacity / AppleRawMaxCapacity is a fallback (mAh ratio)
        let percent: Int
        if currentCapacity > 0 && currentCapacity <= 100 {
            percent = currentCapacity
        } else if appleRawMaxCapacity > 0 {
            percent = min(100, (appleRawCurrentCapacity * 100) / appleRawMaxCapacity)
        } else {
            percent = stateOfCharge > 0 ? stateOfCharge : 0
        }

        // Health%: AppleRawMaxCapacity / DesignCapacity (real mAh ratio)
        // Requires both values in mAh to be meaningful
        let healthPercent: Int
        if designCapacity > 100 && appleRawMaxCapacity > 0 {
            healthPercent = min(100, (appleRawMaxCapacity * 100) / designCapacity)
        } else {
            healthPercent = -1  // unavailable — UI hides it
        }

        // Display capacity: AppleRawMaxCapacity (real current max in mAh)
        let displayCapacity = appleRawMaxCapacity > 0 ? appleRawMaxCapacity : 0

        // Temperature: deciKelvin → Celsius
        let tempCelsius = Double(temperature) / 10.0 - 273.15

        // TotalOperatingTime: battery cumulative run time in hours (from LifetimeData inside BatteryData)
        // NOTE: TotalOperatingTime lives at BatteryData.LifetimeData.TotalOperatingTime (39486h for 2021 laptop)
        var totalOperatingHours = 0
        if let batteryData = dict["BatteryData"] as? [String: Any],
           let lifetime = batteryData["LifetimeData"] as? [String: Any],
           let totalOpHours = lifetime["TotalOperatingTime"] as? Int {
            totalOperatingHours = totalOpHours

        } else {
            // TotalOperatingTime not available
        }

        batteryInfo = BatteryInfo(
            percent: percent,
            charging: isCharging,
            onBattery: !externalConnected && !isCharging,
            cycleCount: cycleCount,
            maxCapacity: displayCapacity,
            designCapacity: designCapacity,
            healthPercent: healthPercent,
            voltage: voltage,
            temperature: tempCelsius,
            timeRemaining: timeRemaining,
            totalOperatingHours: totalOperatingHours
        )

        return batteryInfo
    }

    private func collectUsbDevicesOnce() {
        guard ENABLE_USB_DEVICES else { return }

        // Run ioreg in background to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let devices = self?.performUsbCollection() ?? []
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.devices = DeviceInfo(bluetooth: self.devices.bluetooth, usb: devices)
            }
        }
    }

    private func performUsbCollection() -> [UsbDevice] {
        // Try IOKit approach first (no shell needed)
        var devices = collectUsbViaIOKit()

        // Also try Thunderbolt USB4 devices
        let tbDevices = collectThunderboltUsb4ViaIOKit()
        devices.append(contentsOf: tbDevices)

        return devices.sorted { $0.speedGbps > $1.speedGbps }
    }

    // IOKit-based USB device collection (no shell)
    private func collectUsbViaIOKit() -> [UsbDevice] {
        var devices: [UsbDevice] = []

        let matchingDict = IOServiceMatching("IOUSBHostDevice")
        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator)

        guard result == KERN_SUCCESS else { return devices }

        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            defer {
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }

            // Get device name
            var name = [CChar](repeating: 0, count: 256)
            if IORegistryEntryGetName(service, &name) == KERN_SUCCESS {
                let deviceName = String(cString: name)
                // Skip hubs (they have "Hub" in name or bDeviceClass=9)
                if deviceName.contains("Hub") { continue }
            }

            // Get properties
            var props: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &props, kCFAllocatorDefault, 0) == KERN_SUCCESS,
               let dict = props?.takeRetainedValue() as? [String: Any] {

                // Skip hubs by bDeviceClass
                if let cls = dict["bDeviceClass"] as? Int, cls == 9 || cls == 17 {
                    continue
                }

                // Get speed
                let speed = usbSpeedString(props: dict)

                // Get product name
                let productName = (dict["USB Product Name"] as? String)
                               ?? (dict["kUSBProductString"] as? String)
                               ?? (dict["iProduct"] as? String)
                               ?? "Unknown USB Device"

                devices.append(UsbDevice(name: productName, speed: speed))
            }
        }

        return devices
    }

    // IOKit-based Thunderbolt USB4 device collection
    private func collectThunderboltUsb4ViaIOKit() -> [UsbDevice] {
        var devices: [UsbDevice] = []

        // Use IOServiceGetMatchingServices to find IOThunderboltSwitchUSB4 entries
        // These are top-level entries in IOService plane
        let matchingDict = IOServiceMatching("IOThunderboltSwitchUSB4")
        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator)

        guard result == KERN_SUCCESS else { return devices }

        defer { IOObjectRelease(iterator) }

        var switchCount = 0
        var service = IOIteratorNext(iterator)
        while service != 0 {
            switchCount += 1
            defer {
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }

            // Get properties
            var props: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &props, kCFAllocatorDefault, 0) == KERN_SUCCESS,
               let dict = props?.takeRetainedValue() as? [String: Any] {

                // Check for Device Model Name directly on this entry
                if let modelName = dict["Device Model Name"] as? String {
                    // Filter out Apple internal "iOS" devices (not real iOS devices, they're Thunderbolt internal devices)
                    if modelName == "iOS" { continue }

                    var productName: String
                    if modelName == "246x" {
                        productName = "ASM246x USB4 NVMe SSD Enclosure"
                    } else if let vendorName = (dict["Metadata"] as? [String: Any])?["Device Vendor Name"] as? String {
                        productName = "\(vendorName) \(modelName)"
                    } else {
                        productName = "Thunderbolt USB4 Device (\(modelName))"
                    }
                    devices.append(UsbDevice(name: productName, speed: "USB4"))
                }

                // Also check Metadata for device info
                if let metadata = dict["Metadata"] as? [String: Any],
                   let modelName = metadata["Device Model Name"] as? String,
                   dict["Device Model Name"] == nil {
                    // Filter out Apple internal "iOS" devices
                    if modelName == "iOS" { continue }
                    var productName: String
                    if modelName == "246x" {
                        productName = "ASM246x USB4 NVMe SSD Enclosure"
                    } else if let vendorName = metadata["Device Vendor Name"] as? String {
                        productName = "\(vendorName) \(modelName)"
                    } else {
                        productName = "Thunderbolt USB4 Device (\(modelName))"
                    }
                    devices.append(UsbDevice(name: productName, speed: "USB4"))
                }
            }
        }

        return devices
    }

    private func usbSpeedString(props: [String: Any]) -> String {
        if let speed = props["USBSpeed"] as? Int {
            switch speed {
            case 1: return "USB 1.1"
            case 2: return "USB 2.0"
            case 3: return "USB 2.0 Hi-Speed"
            case 4: return "USB 3.0"
            case 5: return "USB 3.2 Gen1"
            case 6: return "USB 3.2 Gen2"
            case 7: return "USB 3.2 Gen2x2"
            default: return "USB \(speed)"
            }
        }
        return "USB"
    }

    private struct DeviceEntry {
        let lineIndex: Int
        let depth: Int
        let name: String
        var endLineIndex: Int
        var openBraceDepth: Int
        var props: [String: String]
    }

    private func parseIoregEntries(from output: String, className: String) -> [DeviceEntry] {
        let lines = output.components(separatedBy: "\n")
        var deviceEntries: [DeviceEntry] = []

        func countDepth(_ line: String) -> Int {
            var count = 0
            for char in line {
                if char == "|" { count += 1 }
                else if char == " " { continue }
                else { break }
            }
            return count
        }

        func parseKeyValue(_ line: String) -> (String, String)? {
            guard let quoteStart = line.range(of: "\"") else { return nil }
            let afterQuote = line[quoteStart.upperBound...]
            guard let quoteEnd = afterQuote.range(of: "\"") else { return nil }
            let key = String(afterQuote[..<quoteEnd.lowerBound])
            let rest = String(afterQuote[quoteEnd.upperBound...]).trimmingCharacters(in: .whitespaces)
            guard rest.hasPrefix("=") else { return nil }
            let value = String(rest.dropFirst()).trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: ","))
            return (key, value)
        }

        // Find all device lines
        for (i, line) in lines.enumerated() {
            if line.contains("<class \(className)") {
                let depth = countDepth(line)
                var name = "Unknown"
                let stripped = line.trimmingCharacters(in: .whitespaces)
                if let atRange = stripped.range(of: "@") {
                    let beforeAt = stripped[..<atRange.lowerBound]
                    if let nameStart = beforeAt.range(of: "o ", options: .backwards) {
                        name = String(beforeAt[nameStart.upperBound...]).trimmingCharacters(in: .whitespaces)
                    }
                }
                deviceEntries.append(DeviceEntry(lineIndex: i, depth: depth, name: name, endLineIndex: lines.count, openBraceDepth: 0, props: [:]))
            }
        }

        // For each device, find block boundaries by matching braces
        for idx in deviceEntries.indices {
            let start = deviceEntries[idx].lineIndex + 1
            let devDepth = deviceEntries[idx].depth

            var openDepth = -1
            for j in start..<min(start + 20, lines.count) {
                let line = lines[j]
                let d = countDepth(line)
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasSuffix("{") && d > devDepth {
                    openDepth = d
                    deviceEntries[idx].openBraceDepth = openDepth
                    break
                }
            }

            if openDepth < 0 { continue }

            var nestCount = 0
            for j in start..<lines.count {
                let line = lines[j]
                let d = countDepth(line)
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if d == openDepth {
                    if trimmed.hasSuffix("{") { nestCount += 1 }
                    else if trimmed.hasSuffix("}") {
                        nestCount -= 1
                        if nestCount == 0 {
                            deviceEntries[idx].endLineIndex = j
                            break
                        }
                    }
                }
            }
        }

        // Extract properties for each device
        for idx in deviceEntries.indices {
            let start = deviceEntries[idx].lineIndex + 1
            let end = deviceEntries[idx].endLineIndex
            for j in start..<end {
                if let (key, value) = parseKeyValue(lines[j]) {
                    deviceEntries[idx].props[key] = value
                }
            }
        }

        return deviceEntries
    }

    private func usbSpeedString(entry props: [String: String]) -> String {
        // Parse USBSpeed (hex or decimal)
        var speedInt: Int? = nil
        if let speedStr = props["USBSpeed"] {
            if speedStr.hasPrefix("0x") {
                speedInt = Int(speedStr.dropFirst(2), radix: 16)
            } else {
                speedInt = Int(speedStr)
            }
        }

        // Parse UsbLinkSpeed (hex)
        var linkBps: UInt64? = nil
        if let linkStr = props["UsbLinkSpeed"] {
            if linkStr.hasPrefix("0x") {
                linkBps = UInt64(linkStr.dropFirst(2), radix: 16)
            } else {
                linkBps = UInt64(linkStr)
            }
        }

        // Apple's USBSpeed enum values (from IOKit USB.h):
        let spec: String
        switch speedInt {
        case 0: spec = "USB 1.0"
        case 1: spec = "USB 1.1"
        case 2: spec = "USB 2.0"
        case 3: spec = "USB 2.0"
        case 4: spec = "USB 3.0"
        case 5: spec = "USB 3.2 Gen1"
        case 6: spec = "USB 3.2 Gen2"
        case 7: spec = "USB 3.2 Gen2x2"
        case 8: spec = "USB 4"
        default: spec = "USB \(speedInt ?? -1)"
        }

        guard let bps = linkBps, bps > 0 else { return spec }
        let linkGbps = Double(bps) / 1_000_000_000

        let floorBps: Double
        switch speedInt {
        case 2: floorBps = 12_000_000
        case 3: floorBps = 480_000_000
        case 4: floorBps = 5_000_000_000
        case 5: floorBps = 5_000_000_000
        case 6: floorBps = 10_000_000_000
        case 7: floorBps = 20_000_000_000
        case 8: floorBps = 40_000_000_000
        default: floorBps = 0
        }

        if floorBps > 0 && linkGbps > floorBps / 1_000_000_000 + 0.5 {
            return "\(spec) (\(String(format: "%.0f", linkGbps)) Gbps)"
        }
        return spec
    }

    private func usbSpeedString(speed: Int?, linkBps: UInt64?) -> String {
        var props: [String: String] = [:]
        if let s = speed { props["USBSpeed"] = String(s) }
        if let b = linkBps { props["UsbLinkSpeed"] = String(b) }
        return usbSpeedString(entry: props)
    }

    /// Set up IOKit USB device plug/unplug notifications
    private func setupUsbNotifications() {
        guard ENABLE_USB_DEVICES else { return }

        let matchingDict = IOServiceMatching("IOUSBDevice") as NSMutableDictionary

        guard let port = IONotificationPortCreate(kIOMainPortDefault) else {
            fputs("[MiniPulse] IONotificationPortCreate failed\n", stderr)
            return
        }
        usbNotificationPort = port

        let runLoopSource = IONotificationPortGetRunLoopSource(port).takeUnretainedValue()
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .defaultMode)

        // USB device added
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        let addCallback: IOServiceMatchingCallback = { (refcon, iterator) in
            let monitor = Unmanaged<SystemMonitor>.fromOpaque(refcon!).takeUnretainedValue()
            fputs("[MiniPulse] USB device added\n", stderr)
            monitor.handleUsbDeviceChange()
        }

        var result = IOServiceAddMatchingNotification(
            port,
            kIOMatchedNotification,
            matchingDict,
            addCallback,
            selfPtr,
            &usbAddedIterator
        )
        if result != KERN_SUCCESS {
            fputs("[MiniPulse] IOServiceAddMatchingNotification (add) failed: \(result)\n", stderr)
        }

        // Drain initial iterator to arm the notification
        while case let device = IOIteratorNext(usbAddedIterator), device != 0 {
            IOObjectRelease(device)
        }

        // USB device removed
        let removeCallback: IOServiceMatchingCallback = { (refcon, iterator) in
            let monitor = Unmanaged<SystemMonitor>.fromOpaque(refcon!).takeUnretainedValue()
            fputs("[MiniPulse] USB device removed\n", stderr)
            // Drain the iterator
            while case let device = IOIteratorNext(iterator), device != 0 {
                IOObjectRelease(device)
            }
            monitor.handleUsbDeviceChange()
        }

        // Re-create matching dict for removal (iterator consumes it)
        let removeMatchingDict = IOServiceMatching("IOUSBDevice") as NSMutableDictionary
        result = IOServiceAddMatchingNotification(
            port,
            kIOTerminatedNotification,
            removeMatchingDict,
            removeCallback,
            selfPtr,
            &usbRemovedIterator
        )
        if result != KERN_SUCCESS {
            fputs("[MiniPulse] IOServiceAddMatchingNotification (remove) failed: \(result)\n", stderr)
        }

        // Drain initial iterator
        while case let device = IOIteratorNext(usbRemovedIterator), device != 0 {
            IOObjectRelease(device)
        }

        fputs("[MiniPulse] USB notifications setup complete\n", stderr)
    }

    private func handleUsbDeviceChange() {
        refreshQueue.async { [weak self] in
            guard let self = self else { return }
            let devices = self.performUsbCollection()
            DispatchQueue.main.async {
                self.devices = DeviceInfo(bluetooth: self.devices.bluetooth, usb: devices)
            }
        }
    }

    // MARK: - Disk Plug/Unmount Notifications via NSWorkspace

    private func setupDiskNotifications() {
        guard ENABLE_DISK_INFO else { return }

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleDiskMount(_:)),
            name: NSWorkspace.didMountNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleDiskUnmount(_:)),
            name: NSWorkspace.didUnmountNotification,
            object: nil
        )

        fputs("[MiniPulse] Disk notifications setup complete\n", stderr)
    }

    @objc private func handleDiskMount(_ notification: Notification) {
        fputs("[MiniPulse] Disk mounted: \(notification.userInfo ?? [:])\n", stderr)
        refreshDiskCapacity()
    }

    @objc private func handleDiskUnmount(_ notification: Notification) {
        fputs("[MiniPulse] Disk unmounted: \(notification.userInfo ?? [:])\n", stderr)
        refreshDiskCapacity()
    }

    // MARK: - Disk Capacity Collection (startup only)

    // MARK: - Disk Capacity Collection (periodic refresh)

    /// Collect disk info using df -h (always current, works for all mounted filesystems)
    /// Called at startup and periodically via timer
    func performDiskCollection() -> [DiskInfo] {
        var diskList: [DiskInfo] = []

        // System volumes to skip (APFS system partitions — not user-relevant disks)
        // NOTE: /System/Volumes/Data is the same APFS Container as / (shared capacity).
        // We skip it to avoid showing the same physical disk twice.
        let skipMounts = Set([
            "/System/Volumes/VM",
            "/System/Volumes/Preboot",
            "/System/Volumes/Update",
            "/System/Volumes/Hardware",
            "/System/Volumes/xarts",
            "/System/Volumes/iSCPreboot"
            // NOTE: /System/Volumes/Data is intentionally NOT here — we handle it specially below
        ])

        // Skip volumes smaller than 1 GB — these are auxiliary APFS volumes (Preboot, Update,
        // iSCPreboot, xarts, Hardware, etc.) not user-addressable storage.
        // The 1 GB threshold avoids skipping real small external SSDs while filtering all the
        // ~500 MB Apple system auxiliary volumes.
        let MIN_USER_DISK_KB: Double = 1_000_000  // 1 GB in KB

        // Use df -k (kilobytes, POSIX-mandated fixed format) to get real-time free/total.
        // df -k output format (9 columns, always):
        //   Filesystem  1024-blocks  Used  Available  Capacity  Mounted
        //   /dev/disk3s1  239362496  49320960  167367872   23%     /System/Volumes/Data
        // Index:           [1]           [2]      [3]         [4]    [8]
        let dfOut = run("/bin/df", args: ["-k"])
        let dfLines = dfOut.split(separator: "\n", omittingEmptySubsequences: false)

        // Detect if this Mac has a separate Data volume (MacBook Pro style).
        // We detect by looking for a line where the mount point equals exactly "/System/Volumes/Data".
        // We find the mount point by finding the LAST token starting with "/" and NOT containing spaces.
        let hasDataVolume = dfLines.contains { line in
            let tokens = line.split(separator: " ")
            guard let last = tokens.last else { return false }
            let mount = String(last)
            return mount == "/System/Volumes/Data"
        }

        // Build a device->volumeName map ONCE by calling diskutil list -plist.
        // This gives us proper Unicode volume names (Chinese, emoji) even though
        // df -k returns "?" for non-ASCII mount points due to POSIX locale.
        var deviceToVolumeName: [String: String] = [:]
        let diskutilTask = Process()
        diskutilTask.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
        diskutilTask.arguments = ["list", "-plist"]
        let diskutilPipe = Pipe()
        diskutilTask.standardOutput = diskutilPipe
        diskutilTask.standardError = FileHandle.nullDevice
        try? diskutilTask.run()
        diskutilTask.waitUntilExit()
        let diskutilData = diskutilPipe.fileHandleForReading.readDataToEndOfFile()
        if let diskutilPlist = try? PropertyListSerialization.propertyList(from: diskutilData, format: nil) as? [String: Any],
           let allDisks = diskutilPlist["AllDisksAndPartitions"] as? [[String: Any]] {
            for disk in allDisks {
                if let partitions = disk["Partitions"] as? [[String: Any]] {
                    for partition in partitions {
                        if let devID = partition["DeviceIdentifier"] as? String,
                           let volName = partition["VolumeName"] as? String {
                            deviceToVolumeName[devID] = volName
                        }
                    }
                }
                if let apfsVols = disk["APFSVolumes"] as? [[String: Any]] {
                    for vol in apfsVols {
                        if let devID = vol["DeviceIdentifier"] as? String,
                           let volName = vol["VolumeName"] as? String {
                            deviceToVolumeName[devID] = volName
                        }
                    }
                }
            }
        }

        for line in dfLines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            if trimmed.hasPrefix("Filesystem") { continue }

            let parts = trimmed.split(separator: " ")
            guard parts.count >= 9 else { continue }

            // Skip non-filesystem lines (e.g. "map auto_home" has non-numeric KB value)
            guard Double(parts[1]) != nil else { continue }

            // Mount point is always the LAST token starting with "/"
            guard let mountIdx = parts.lastIndex(where: { $0.hasPrefix("/") }) else { continue }
            let mountPoint = String(parts[mountIdx])
            if skipMounts.contains(mountPoint) { continue }

            // Skip App Translocation paths (macOS Gatekeeper quarantine temporary mounts for downloaded apps)
            if mountPoint.contains("AppTranslocation") { continue }

            // Skip map entries (auto_home network share mapping — not a real disk)
            if mountPoint.hasPrefix("map ") { continue }

            // Skip SMB/CIFS network mounts (displayed separately as //user@host/share)
            if mountPoint.hasPrefix("//") { continue }

            // Skip Time Machine local snapshots (com.apple.TimeMachine.localsnapshots, .timemachine)
            if mountPoint.contains(".timemachine") || mountPoint.contains("TimeMachine") { continue }

            // On Macs with separate Data volume (e.g. MacBook Pro), skip root snapshot
            // because Data volume shows real usage (Finder reads from Data)
            // On Macs without Data volume (e.g. M4 Mac mini), keep root "/"
            if mountPoint == "/" && hasDataVolume {
                continue
            }

            // df -k always gives sizes in KB: [1]=total, [2]=used, [3]=avail
            let totalKB = Double(parts[1]) ?? 0
            let usedKB = Double(parts[2]) ?? 0
            let freeKB = Double(parts[3]) ?? 0
            let usePct = Double(parts[4].trimmingCharacters(in: CharacterSet(charactersIn: "%"))) ?? 0

            // Skip pseudo-filesystems: devfs (<1MB), map auto_home (0KB), etc.
            // Also skip if totalKB < 1 GB — these are auxiliary APFS system volumes, not real storage
            guard totalKB >= MIN_USER_DISK_KB else { continue }

            let totalGB = totalKB / 1024 / 1024
            let usedGB = usedKB / 1024 / 1024
            let freeGB = freeKB / 1024 / 1024

            // Get display name from mount point.
            // NOTE: df -k on macOS outputs mount points with non-ASCII chars (Chinese, emoji)
            // replaced by "?" due to POSIX locale. We get proper volume names by calling
            // "diskutil list -plist" once and building a device->label map.
            var name: String
            if mountPoint == "/" || mountPoint == "/System/Volumes/Data" {
                name = "Macintosh HD"
            } else {
                // Extract device identifier (e.g. "disk5s1") from "/dev/disk5s1"
                let fs = parts[0]
                let deviceIdentifier: String
                if fs.hasPrefix("/dev/") {
                    deviceIdentifier = String(fs.dropFirst("/dev/".count))
                } else {
                    deviceIdentifier = String(fs)
                }

                // Look up volume name from the pre-built map (diskutil list -plist result)
                let resolvedName = deviceToVolumeName[deviceIdentifier]
                name = resolvedName ?? (mountPoint.hasPrefix("/Volumes/") ? String(mountPoint.dropFirst("/Volumes/".count)) : mountPoint)
            }

            diskList.append(DiskInfo(
                name: name,
                mountpoint: mountPoint,
                totalGB: totalGB,
                usedGB: usedGB,
                freeGB: freeGB,
                percent: usePct,
                isMounted: true
            ))
        }

        return diskList
    }

    /// Called at startup to collect disk capacity info
    private func collectDiskInfoOnce() {
        guard ENABLE_DISK_INFO else { return }

        refreshQueue.async { [weak self] in
            guard let self = self else { return }
            let disks = self.performDiskCollection()
            DispatchQueue.main.async {
                self.disks = disks
            }
        }
    }

    // MARK: - Manual refresh for disk capacity (called by UI button if needed)

    func refreshDiskCapacity() {
        guard ENABLE_DISK_INFO else { return }
        refreshQueue.async { [weak self] in
            guard let self = self else { return }
            let disks = self.performDiskCollection()
            DispatchQueue.main.async {
                self.disks = disks
            }
        }
    }

    // MARK: - GPU Info Collection (startup only — name/VRAM from system_profiler)

    private func collectGpuInfoOnce() {
        guard ENABLE_GPU_INFO else { return }

        refreshQueue.async { [weak self] in
            guard let self = self else { return }
            var gpuName = "Apple Silicon GPU"
            var gpuVRAM = 0
            let spOut = self.run("/usr/sbin/system_profiler", args: ["SPDisplaysDataType", "-json"], timeout: 10)
            if let spData = try? JSONSerialization.jsonObject(with: spOut.data(using: .utf8) ?? Data()) as? [String: Any],
               let displays = (spData["SPDisplaysDataType"] as? [[String: Any]])?.first {
                if let name = displays["spdisplays_name"] as? String { gpuName = name }
                if let vram = displays["spdisplays_vram"] as? Int { gpuVRAM = vram }
                if let chip = displays["sppci_cores"] as? String {
                    // Chip info available but we primarily use name/VRAM
                }
            }
            // Fallback: if VRAM is 0, estimate from system memory
            if gpuVRAM == 0 {
                let memTotal = ProcessInfo.processInfo.physicalMemory
                gpuVRAM = Int(memTotal / 1024 / 1024)
            }
            DispatchQueue.main.async {
                self.sysInfo.gpuName = gpuName
                self.sysInfo.gpuVRAM = gpuVRAM
            }
        }
    }

    // MARK: - Display Info Collection (startup only)

    private func collectDisplayInfoOnce() {
        guard ENABLE_DISPLAY_INFO else { return }

        refreshQueue.async { [weak self] in
            guard let self = self else { return }
            let resolutions = self.performDisplayCollection()
            DispatchQueue.main.async {
                self.sysInfo.displayResolutions = resolutions
            }
        }
    }

    // MARK: - Top Processes Collection (startup + manual refresh only)

    private func collectTopProcessesOnce() {
        guard ENABLE_TOP_PROCESSES else { return }

        refreshQueue.async { [weak self] in
            guard let self = self else { return }
            let (cpu, mem) = self.performTopProcessesCollection()
            DispatchQueue.main.async {
                self.topCPU = cpu
                self.topMem = mem
            }
        }
    }

    func refreshTopProcesses() {
        guard ENABLE_TOP_PROCESSES else { return }

        refreshQueue.async { [weak self] in
            guard let self = self else { return }
            let (cpu, mem) = self.performTopProcessesCollection()
            DispatchQueue.main.async {
                self.topCPU = cpu
                self.topMem = mem
            }
        }
    }

    private func performTopProcessesCollection() -> ([ProcessEntry], [ProcessEntry]) {
        // Single ps call — collect all columns at once
        let psOut = run("/bin/ps", args: ["-aceo", "pid,pcpu,rss,comm"])
        let allProcesses: [ProcessEntry] = psOut.components(separatedBy: "\n").dropFirst().compactMap { line in
            let cols = line.split(separator: " ", omittingEmptySubsequences: true)
            guard cols.count >= 4 else { return nil }
            let pid = Int(cols[0]) ?? 0
            let cpu = Double(cols[1]) ?? 0
            let memKB = Double(cols[2]) ?? 0
            let name = cols[3...].joined(separator: " ")
            guard pid > 0, memKB >= 0 else { return nil }
            return ProcessEntry(pid: pid, name: name, cpuPercent: cpu, memPercent: 0, memMB: memKB / 1024)
        }

        let topCPU = allProcesses
            .sorted { $0.cpuPercent > $1.cpuPercent }
            .prefix(10)
            .map { $0 }

        let topMem = allProcesses
            .sorted { $0.memMB > $1.memMB }
            .prefix(10)
            .map { $0 }

        return (Array(topCPU), Array(topMem))
    }


    private func collectBluetoothDevicesOnce() {
        guard ENABLE_BT_DEVICES else { return }

        refreshQueue.async { [weak self] in
            guard let self = self else { return }
            let devices = self.performBluetoothCollection()
            DispatchQueue.main.async {
                self.devices = DeviceInfo(bluetooth: devices, usb: self.devices.usb)
            }
        }
    }

    private func performBluetoothCollection() -> [BluetoothDevice] {
        var btDevices: [BluetoothDevice] = []
        let btOut = run("/usr/sbin/system_profiler", args: ["SPBluetoothDataType", "-json"], timeout: 10)
        guard let btData = try? JSONSerialization.jsonObject(with: btOut.data(using: .utf8) ?? Data()) as? [String: Any],
              let btArray = btData["SPBluetoothDataType"] as? [[String: Any]],
              let btFirst = btArray.first else {
            return []
        }
        // Connected devices
        if let connected = btFirst["device_connected"] as? [[String: Any]] {
            for entry in connected {
                for (name, props) in entry {
                    if let propsDict = props as? [String: Any] {
                        btDevices.append(BluetoothDevice(name: name, status: "connected", type: propsDict["device_minorType"] as? String ?? "Device"))
                    }
                }
            }
        }
        // Paired but not connected devices
        if let notConnected = btFirst["device_not_connected"] as? [[String: Any]] {
            for entry in notConnected {
                for (name, props) in entry {
                    if let propsDict = props as? [String: Any] {
                        btDevices.append(BluetoothDevice(name: name, status: "paired", type: propsDict["device_minorType"] as? String ?? "Device"))
                    }
                }
            }
        }
        return btDevices
    }

    func refreshBluetoothDevices() {
        guard ENABLE_BT_DEVICES else { return }
        refreshQueue.async { [weak self] in
            guard let self = self else { return }
            let devices = self.performBluetoothCollection()
            DispatchQueue.main.async {
                self.devices = DeviceInfo(bluetooth: devices, usb: self.devices.usb)
            }
        }
    }

    private func performDisplayCollection() -> [String] {
        var resolutions: [String] = []
        let spOut = run("/usr/sbin/system_profiler", args: ["SPDisplaysDataType", "-json"], timeout: 10)
        guard let spData = try? JSONSerialization.jsonObject(with: spOut.data(using: .utf8) ?? Data()) as? [String: Any],
              let displays = spData["SPDisplaysDataType"] as? [[String: Any]] else {
            return []
        }
        for d in displays {
            if let ndrvs = d["spdisplays_ndrvs"] as? [[String: Any]] {
                for ndrv in ndrvs {
                    if let px = ndrv["_spdisplays_pixels"] as? String, !px.isEmpty {
                        resolutions.append(px)
                        break
                    }
                }
            }
        }
        return resolutions
    }

    private func readCPUFast() -> CpuInfo {
        var info = CpuInfo()

        // Single sysctl call for all CPU topology keys
        let sysctlOut = run("/usr/sbin/sysctl", args: ["-n", "hw.physicalcpu", "hw.logicalcpu", "hw.perflevel0.physicalcpu", "hw.perflevel1.physicalcpu"])
        let parts = sysctlOut.split(whereSeparator: { $0.isWhitespace || $0.isNewline })
        let physC = parts.count > 0 ? Int(parts[0]) ?? 0 : 0
        let logC = parts.count > 1 ? Int(parts[1]) ?? 0 : 0
        let pCores = parts.count > 2 ? UInt64(parts[2]) ?? 4 : 4
        let eCores = parts.count > 3 ? UInt64(parts[3]) ?? 6 : 6
        info.physical = physC
        info.logical = logC
        let pCoreMax = 4.05  // GHz
        let eCoreMax = 2.13  // GHz
        let totalCores = pCores + eCores
        if totalCores > 0 {
            info.freqMax = (pCoreMax * Double(pCores) + eCoreMax * Double(eCores)) / Double(totalCores)
        } else {
            info.freqMax = 3.5  // fallback
        }

        // Overall CPU: use Mach API (host_processor_info) — no blocking, no shell spawn
        // Aggregates all per-core ticks to get overall CPU %
        let (perCorePcts, tickDeltas) = getPerCoreCPUWithDelta()

        // Sum tick deltas across all cores for overall CPU %
        var totalUser: UInt64 = 0, totalSystem: UInt64 = 0, totalIdle: UInt64 = 0, totalNice: UInt64 = 0
        for delta in tickDeltas {
            totalUser += UInt64(delta.user)
            totalSystem += UInt64(delta.system)
            totalIdle += UInt64(delta.idle)
            totalNice += UInt64(delta.nice)
        }
        let totalTicks = totalUser + totalSystem + totalIdle + totalNice
        if totalTicks > 0 {
            let usedTicks = totalUser + totalSystem + totalNice
            info.percent = Double(usedTicks) / Double(totalTicks) * 100
            info.timesUser = Double(totalUser) / Double(totalTicks) * 100
            info.timesSystem = Double(totalSystem) / Double(totalTicks) * 100
            info.timesIdle = Double(totalIdle) / Double(totalTicks) * 100
            info.timesNice = Double(totalNice) / Double(totalTicks) * 100
        }
        if !perCorePcts.isEmpty {
            info.perCore = perCorePcts
        } else {
            info.perCore = Array(repeating: 0, count: logC)
        }

        // Estimate current freq from usage
        if info.freqMax > 0 {
            info.freqCurrent = info.freqMax * (0.3 + 0.7 * (info.percent / 100.0).clamped(to: 0...1))
        }

        return info
    }

    private func getPerCoreCPUWithDelta() -> (perCore: [Double], tickDeltas: [(user: Double, system: Double, idle: Double, nice: Double)]) {
        var numCPUs: natural_t = 0
        var cpuLoad: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0

        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUs, &cpuLoad, &numCpuInfo)
        guard result == KERN_SUCCESS, let load = cpuLoad else { return ([], []) }

        let cpuLoadInfoSize = Int32(CPU_STATE_MAX)
        var perCore: [Double] = []
        var currentTicks: [(user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)] = []
        var tickDeltas: [(user: Double, system: Double, idle: Double, nice: Double)] = []

        for i in 0..<Int(numCPUs) {
            let offset = Int(cpuLoadInfoSize) * i
            let user: UInt64 = UInt64(load[offset + Int(CPU_STATE_USER)])
            let system: UInt64 = UInt64(load[offset + Int(CPU_STATE_SYSTEM)])
            let idle: UInt64 = UInt64(load[offset + Int(CPU_STATE_IDLE)])
            let nice: UInt64 = UInt64(load[offset + Int(CPU_STATE_NICE)])
            currentTicks.append((user: user, system: system, idle: idle, nice: nice))

            // First read — initialize prevCpuTicks, return 0 for this cycle
            if prevCpuTicks.isEmpty {
                perCore.append(0)
                tickDeltas.append((user: 0, system: 0, idle: 0, nice: 0))
            } else if i < prevCpuTicks.count {
                let prev = prevCpuTicks[i]
                let userDelta = Double(user) - Double(prev.user)
                let systemDelta = Double(system) - Double(prev.system)
                let idleDelta = Double(idle) - Double(prev.idle)
                let niceDelta = Double(nice) - Double(prev.nice)
                let totalDelta = userDelta + systemDelta + idleDelta + niceDelta
                let usedDelta = userDelta + systemDelta + niceDelta
                perCore.append(totalDelta > 0 ? usedDelta / totalDelta * 100 : 0)
                tickDeltas.append((user: userDelta, system: systemDelta, idle: idleDelta, nice: niceDelta))
            } else {
                perCore.append(0)
                tickDeltas.append((user: 0, system: 0, idle: 0, nice: 0))
            }
        }

        let size = vm_size_t(numCpuInfo) * vm_size_t(MemoryLayout<integer_t>.stride)
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: load), size)

        // Store current ticks for next delta calculation
        prevCpuTicks = currentTicks

        return (perCore, tickDeltas)
    }

    private func refreshBaseInfo() {
        sysInfo.userName = NSFullUserName()
        sysInfo.hostname = Host.current().localizedName ?? ProcessInfo.processInfo.hostName

        let r = run("/usr/sbin/sysctl", args: ["-n", "kern.osproductversion"])
        sysInfo.osVersion = "macOS \(r.trimmingCharacters(in: .whitespacesAndNewlines))"

        let build = run("/usr/sbin/sysctl", args: ["-n", "kern.osversion"])
        sysInfo.osVersion += " (\(build.trimmingCharacters(in: .whitespacesAndNewlines)))"

        let modelNum = run("/usr/sbin/sysctl", args: ["-n", "hw.model"])
        sysInfo.hwModel = modelNum.trimmingCharacters(in: .whitespacesAndNewlines)

        // Get human-readable machine model name
        let spOut = run("/usr/sbin/system_profiler", args: ["SPHardwareDataType", "-json"])
        if let spData = try? JSONSerialization.jsonObject(with: spOut.data(using: .utf8) ?? Data()) as? [String: Any],
           let hardware = (spData["SPHardwareDataType"] as? [[String: Any]])?.first,
           let modelName = hardware["machine_name"] as? String {
            sysInfo.machineModelName = modelName
        } else {
            sysInfo.machineModelName = sysInfo.hwModel
        }

        // Detect if this is a laptop (has internal battery)
        // Use pmset -g batt: if output contains "%" or "Battery Power", it's a laptop
        // (Mac desktops may show "AC Power" but without percentage)
        let pmsetOut = run("/usr/bin/pmset", args: ["-g", "batt"])
        let hasBatteryPercent = pmsetOut.contains("%")
        let hasBatteryPower = pmsetOut.contains("Battery Power")
        sysInfo.isLaptop = hasBatteryPercent || hasBatteryPower
        print("[MiniPulse] isLaptop detection: pmset output=\(pmsetOut.trimmingCharacters(in: .whitespacesAndNewlines)), isLaptop=\(sysInfo.isLaptop)")

        let r2 = run("/usr/sbin/sysctl", args: ["-n", "kern.boottime"])
        if let match = r2.range(of: "\\d+", options: .regularExpression),
           let ts = TimeInterval(r2[match]) {
            bootTime = Date(timeIntervalSince1970: ts)
        }
    }

    private func refresh() {
        refreshQueue.async { [weak self] in
            self?.collectAll()
        }
    }

    private func collectAll() {
        collectAllOnBackground()
    }

    private func collectAllOnBackground() {
        // ── CPU ──
        let cpuInfo = readCPUFast()

        let uptime = Date().timeIntervalSince(self.bootTime)
        let hours = Int(uptime) / 3600
        let minutes = Int(uptime) % 3600 / 60
        let seconds = Int(uptime) % 60
        _ = hours; _ = minutes; _ = seconds  // unused but keep uptime calc

        // ── Memory ──
        // Single sysctl call for memory topology
        let memOut = run("/usr/sbin/sysctl", args: ["-n", "hw.memsize", "hw.pagesize"])
        let memParts = memOut.split(whereSeparator: { $0.isWhitespace || $0.isNewline })
        let memTotal = memParts.count > 0 ? UInt64(memParts[0]) ?? 0 : 0
        let pageSize = memParts.count > 1 ? UInt64(memParts[1]) ?? 4096 : 4096
        let vmStat = run("/usr/bin/vm_stat")

        // Single-pass parse: extract all "Pages free: 123" entries into a dictionary
        var vmDict: [String: UInt64] = [:]
        let vmLines = vmStat.components(separatedBy: "\n")
        for line in vmLines {
            guard let colonIdx = line.firstIndex(of: ":") else { continue }
            let key = String(line[..<colonIdx]).trimmingCharacters(in: .whitespaces)
            let restIdx = line.index(after: colonIdx)
            guard restIdx < line.endIndex else { continue }
            let rest = line[restIdx...].trimmingCharacters(in: .whitespaces)
            if let numStr = rest.split(separator: " ").first {
                let clean = numStr.replacingOccurrences(of: ".", with: "")
                if let val = UInt64(clean) {
                    vmDict[key] = val
                }
            }
        }

        let freePages = vmDict["Pages free"] ?? 0
        let activePages = vmDict["Pages active"] ?? 0
        let wiredPages = vmDict["Pages wired down"] ?? 0
        let compressedPages = vmDict["Pages compressed"] ?? 0
        let inactivePages = vmDict["Pages inactive"] ?? 0
        let speculativePages = vmDict["Pages speculative"] ?? 0
        let purgeablePages = vmDict["Pages purgeable"] ?? 0

        // If ALL page counts are 0, the parsing failed - skip this update to avoid bogus readings
        let allZero = freePages == 0 && activePages == 0 && wiredPages == 0 && compressedPages == 0
        guard !allZero else { return }

        // macOS memory model:
        // - "Used" (Activity Monitor) = total - free - inactive - speculative
        // - "Available" = free + inactive + speculative + purgeable (reclaimable cache)
        let freeMemBytes = freePages &* pageSize
        let inactiveMemBytes = inactivePages &* pageSize
        let speculativeMemBytes = speculativePages &* pageSize
        let purgeableMemBytes = purgeablePages &* pageSize
        let usedMem: UInt64
        if freeMemBytes >= memTotal {
            usedMem = 0
        } else {
            let remaining = memTotal &- freeMemBytes
            if inactiveMemBytes >= remaining {
                usedMem = 0
            } else {
                let remaining2 = remaining &- inactiveMemBytes
                if speculativeMemBytes >= remaining2 {
                    usedMem = 0
                } else {
                    usedMem = remaining2 &- speculativeMemBytes
                }
            }
        }
        // available = truly free + reclaimable (inactive + speculative + purgeable)
        let availableMemBytes = freeMemBytes &+ inactiveMemBytes &+ speculativeMemBytes &+ purgeableMemBytes
        let memPct = memTotal > 0 ? Double(usedMem) / Double(memTotal) * 100 : 0

        // Swap
        let swapOut = run("/usr/sbin/sysctl", args: ["-n", "vm.swapusage"])
        var swapTotal: UInt64 = 0, swapUsed: UInt64 = 0
        let swapParts = swapOut.components(separatedBy: " ").filter { !$0.isEmpty }
        if swapParts.count >= 3 {
            swapTotal = parseMB(swapParts[2])
            swapUsed = parseMB(swapParts[0])
        }
        let swapPct = swapTotal > 0 ? Double(swapUsed) / Double(swapTotal) * 100 : 0

        // ── IP Addresses — auto-detect interfaces that actually have IPs via ifconfig ──
        let ifconfigOut = lastIfconfig
        var ips: [NetworkInterface] = []
        // Skip virtual/Apple-internal interface prefixes
        let skipPrefixes = ["utun", "awdl", "llw", "bridge", "lo", "gif", "stf", "ap", "anpi", "appl", "llap", "ipsec"]
        // Split ifconfig output into interface blocks (each starts with non-whitespace line containing ":")
        let lines = ifconfigOut.components(separatedBy: "\n")
        var currentIface: String?
        var currentBlock = ""
        for line in lines {
            // Skip empty lines
            if line.isEmpty { continue }
            // New interface block starts only when line has NO leading whitespace and contains ":"
            // Lines starting with whitespace (tab/space) are continuation of previous interface block
            let hasLeadingWhitespace = line.first?.isWhitespace ?? false
            if !hasLeadingWhitespace, let colonIdx = line.firstIndex(of: ":") {
                let name = String(line[..<colonIdx])
                // If we already have a block and found IPs in it, save them
                if let prevIface = currentIface, !currentBlock.isEmpty {
                    if let inetRange = currentBlock.range(of: "inet ") {
                        // Extract IP after "inet "
                        let ipStart = inetRange.upperBound
                        var ipEnd = ipStart
                        while ipEnd < currentBlock.endIndex && currentBlock[ipEnd].isNumber { ipEnd = currentBlock.index(ipEnd, offsetBy: 1) }
                        while ipEnd < currentBlock.endIndex && currentBlock[ipEnd] != " " && currentBlock[ipEnd] != "\n" { ipEnd = currentBlock.index(ipEnd, offsetBy: 1) }
                        let ip = String(currentBlock[ipStart..<ipEnd])
                        if !ip.isEmpty {
                            // Determine interface type from media line (Base-T = wired Ethernet, otherwise Wi-Fi)
                            var label = prevIface
                            if let mediaRange = currentBlock.range(of: "media:") {
                                // Find end of media line (next newline)
                                let afterMediaStart = mediaRange.upperBound
                                var afterMedia = ""
                                if let newlineIdx = currentBlock[afterMediaStart...].firstIndex(of: "\n") {
                                    afterMedia = String(currentBlock[afterMediaStart..<newlineIdx])
                                } else {
                                    afterMedia = String(currentBlock[afterMediaStart...])
                                }
                                if afterMedia.contains("Base-") || afterMedia.contains("100Base") {
                                    label = "Ethernet"
                                } else {
                                    label = "Wi-Fi"
                                }
                            }
                            ips.append(NetworkInterface(iface: prevIface, ip: ip, label: label))
                            knownIfaceNames.insert(prevIface)
                        }
                    }
                }
                currentIface = name
                currentBlock = line + "\n"
            } else {
                currentBlock += line + "\n"
            }
        }
        // Don't forget the last interface block
        if let prevIface = currentIface, !currentBlock.isEmpty {
            if let inetRange = currentBlock.range(of: "inet ") {
                let ipStart = inetRange.upperBound
                var ipEnd = ipStart
                while ipEnd < currentBlock.endIndex && currentBlock[ipEnd].isNumber { ipEnd = currentBlock.index(ipEnd, offsetBy: 1) }
                while ipEnd < currentBlock.endIndex && currentBlock[ipEnd] != " " && currentBlock[ipEnd] != "\n" { ipEnd = currentBlock.index(ipEnd, offsetBy: 1) }
                let ip = String(currentBlock[ipStart..<ipEnd])
                if !ip.isEmpty {
                    var label = prevIface
                    if let mediaRange = currentBlock.range(of: "media:") {
                        let afterMediaStart = mediaRange.upperBound
                        var afterMedia = ""
                        if let newlineIdx = currentBlock[afterMediaStart...].firstIndex(of: "\n") {
                            afterMedia = String(currentBlock[afterMediaStart..<newlineIdx])
                        } else {
                            afterMedia = String(currentBlock[afterMediaStart...])
                        }
                        if afterMedia.contains("Base-") || afterMedia.contains("100Base") {
                            label = "Ethernet"
                        } else {
                            label = "Wi-Fi"
                        }
                    }
                    ips.append(NetworkInterface(iface: prevIface, ip: ip, label: label))
                    knownIfaceNames.insert(prevIface)
                }
            }
        }
        // Filter out non-physical interfaces
        ips = ips.filter { iface in
            !skipPrefixes.contains(where: { iface.iface.hasPrefix($0) })
        }
        // Build type map: interface name → label (Ethernet/Wi-Fi) from media detection
        let ifaceTypeMap = Dictionary(uniqueKeysWithValues: ips.map { ($0.iface, $0.label) })
        knownIfaceNames.formUnion(ips.map { $0.iface })

        // ── Network — single-pass parse, compute both aggregate and per-interface simultaneously
        let netStatOut = run("/usr/sbin/netstat", args: ["-ib"])
        let netLines = netStatOut.components(separatedBy: "\n")

        // Pre-filter parsed lines once
        let parsedLines: [(iface: String, ibytes: UInt64, obytes: UInt64)] = netLines.compactMap { line in
            let cols = line.split(separator: " ", omittingEmptySubsequences: true)
            guard cols.count >= 10 else { return nil }
            let ifaceName = String(cols[0])
            guard !ifaceName.contains("*"),
                  !ifaceName.hasPrefix("utun"), !ifaceName.hasPrefix("awdl"),
                  !ifaceName.hasPrefix("llw"), !ifaceName.hasPrefix("bridge"),
                  !ifaceName.hasPrefix("lo") else { return nil }
            guard let ibytes = UInt64(cols[6]), let obytes = UInt64(cols[9]) else { return nil }
            return (ifaceName, ibytes, obytes)
        }

        // Aggregate totals (dedup by interface name — take first occurrence only)
        var seenIfaces: Set<String> = []
        var totalSent: UInt64 = 0, totalRecv: UInt64 = 0
        for entry in parsedLines {
            if !seenIfaces.contains(entry.iface) {
                seenIfaces.insert(entry.iface)
                totalRecv += entry.ibytes
                totalSent += entry.obytes
            }
        }
        let sentMBs = (totalSent >= prevNetSent && prevNetSent > 0) ? Double(totalSent - prevNetSent) / 1024 / 1024 / 5 : 0
        let recvMBs = (totalRecv >= prevNetRecv && prevNetRecv > 0) ? Double(totalRecv - prevNetRecv) / 1024 / 1024 / 5 : 0
        prevNetSent = totalSent
        prevNetRecv = totalRecv

        // Per-interface stats (dedup via perIface == nil)
        var perIface: [String: IfaceStats] = [:]
        var prevIfaceBytes: [String: (sent: UInt64, recv: UInt64)] = ifacBytes
        for entry in parsedLines {
            guard perIface[entry.iface] == nil else { continue }
            let prev = prevIfaceBytes[entry.iface]
            let sentRate: Double
            let recvRate: Double
            if let p = prev, p.sent > 0, entry.obytes >= p.sent {
                sentRate = Double(entry.obytes - p.sent) / 1024 / 1024 / 5
            } else {
                sentRate = 0
            }
            if let p = prev, p.recv > 0, entry.ibytes >= p.recv {
                recvRate = Double(entry.ibytes - p.recv) / 1024 / 1024 / 5
            } else {
                recvRate = 0
            }
            prevIfaceBytes[entry.iface] = (entry.obytes, entry.ibytes)
            var stats = IfaceStats(label: ifaceTypeMap[entry.iface] ?? entry.iface)
            stats.recvMBs = recvRate
            stats.sentMBs = sentRate
            perIface[entry.iface] = stats
        }
        // Persist for next cycle
        ifacBytes = prevIfaceBytes

        // ── Disk I/O via iostat (1-second sample, ASYNC — no longer blocks timer loop) ──
        // Read the latest cached values (updated by background diskIOAccumulatorTimer)
        let diskReadBytes = lastDiskIO.readMB
        let diskWriteBytes = lastDiskIO.writeMB

        // Parse "228Gi", "12Gi", "1.8Ti" etc. into GB as Double
        func parseDiskSize(_ s: String) -> Double {
            let trimmed = s.trimmingCharacters(in: .whitespaces)
            let numStr = String(trimmed.dropLast(2))  // drop "Gi", "Ti", "Mi", "Ki"
            let multiplier: Double
            if trimmed.hasSuffix("Ti") { multiplier = 1024 }
            else if trimmed.hasSuffix("Gi") { multiplier = 1 }
            else if trimmed.hasSuffix("Mi") { multiplier = 1.0 / 1024 }
            else if trimmed.hasSuffix("Ki") { multiplier = 1.0 / 1024 / 1024 }
            else { return 0 }
            return (Double(numStr) ?? 0) * multiplier
        }

        // ── GPU info (conditionally enabled) ──
        var gpuUtil: Int? = nil
        var gpuName = "Apple Silicon GPU"
        var gpuVRAM = 0
        var histSlice: [Int] = Array(repeating: 0, count: 20)
        var ioregOut = ""

        if ENABLE_GPU_INFO {
            // GPU utilization from ioreg — use 1-second cache to avoid excessive syscalls
            // GPU name/VRAM is collected once at startup via collectGpuInfoOnce()
            let now = Date()
            if now.timeIntervalSince(ioregCache.timestamp) < 1.0 {
                gpuUtil = ioregCache.utilization
            } else {
                ioregOut = run("/usr/sbin/ioreg", args: ["-r", "-c", "AGXAccelerator"])
                for line in ioregOut.components(separatedBy: "\n") {
                    if line.contains("Device Utilization %") {
                        if let range = line.range(of: "\"Device Utilization %\"=([0-9]+)", options: .regularExpression) {
                            let numRange = line[range].replacingOccurrences(of: "\"Device Utilization %\"=", with: "")
                            gpuUtil = Int(numRange)
                        }
                    }
                }
                ioregCache = (now, gpuUtil)
            }
            // Re-use GPU name/VRAM from startup collection (don't re-run system_profiler every tick)
            gpuName = self.sysInfo.gpuName
            gpuVRAM = self.sysInfo.gpuVRAM
        }
        // GPU history update — always keep last 20 samples
        if let util = gpuUtil {
            let idx = gpuHistIdx
            let safeIdx = (idx >= 0) ? (idx % 20) : 0
            gpuHistory[safeIdx] = util
            gpuHistIdx = idx &+ 1
        }
        let count = min(gpuHistIdx, 20)
        if gpuHistIdx < 20 {
            histSlice = Array(gpuHistory[0..<count])
        } else {
            let head = gpuHistIdx % 20
            histSlice = Array(gpuHistory[head..<20]) + Array(gpuHistory[0..<head])
        }

        // ── Battery via IOKit (AppleSmartBattery) ──
        let batteryInfo: BatteryInfo? = ENABLE_BATTERY_INFO ? collectBatteryInfoViaIOKit() : nil

        // NOTE: Display resolution is collected at startup via collectDisplayInfoOnce(), not in the timer loop.
        // We keep using self.sysInfo.displayResolutions to avoid re-collecting.
        var displayResolutions: [String] = []
        if ENABLE_DISPLAY_INFO {
            // Re-use already-collected value; timer loop does not re-collect
            displayResolutions = self.sysInfo.displayResolutions
        }

        // ── Top Processes (conditionally enabled) ──
        // NOTE: Top processes are collected at startup via collectTopProcessesOnce()
        // and refreshed periodically in the timer loop (every TOP_REFRESH_INTERVAL cycles).
        // Keep existing values to avoid re-collection on every tick.
        var topCpuOut = self.topCPU
        var topMemOut = self.topMem
        if !ENABLE_TOP_PROCESSES {
            topCpuOut = []
            topMemOut = []
        }
        // Refresh top processes every N cycles
        self.topRefreshCounter += 1
        if ENABLE_TOP_PROCESSES && self.topRefreshCounter >= self.TOP_REFRESH_INTERVAL {
            self.topRefreshCounter = 0
            let (cpu, mem) = self.performTopProcessesCollection()
            topCpuOut = cpu
            topMemOut = mem
        }

        // ── Bluetooth & USB devices (conditionally enabled) ──
        // NOTE: USB/Bluetooth collection is handled by collectUsbDevicesOnce()
        // and collectBluetoothDevicesOnce() + IOKit event listeners.
        // We also do periodic refresh every BT_USB_REFRESH_INTERVAL cycles.
        var btDevices: [BluetoothDevice] = []
        if ENABLE_BT_DEVICES {
            btDevices = self.devices.bluetooth
        }
        // Refresh bluetooth every N cycles (expensive - system_profiler takes ~1s)
        self.btRefreshCounter += 1
        if ENABLE_BT_DEVICES && self.btRefreshCounter >= self.BT_USB_REFRESH_INTERVAL {
            self.btRefreshCounter = 0
            btDevices = self.performBluetoothCollection()
        }
        // Refresh USB every N cycles (IOKit tree traversal is expensive)
        self.usbRefreshCounter += 1
        if ENABLE_USB_DEVICES && self.usbRefreshCounter >= self.BT_USB_REFRESH_INTERVAL {
            self.usbRefreshCounter = 0
            // Refresh USB on a separate async call to avoid blocking the collection queue
            self.refreshQueue.async { [weak self] in
                guard let self = self else { return }
                let usbDevices = self.performUsbCollection()
                DispatchQueue.main.async {
                    self.devices = DeviceInfo(bluetooth: self.devices.bluetooth, usb: usbDevices)
                }
            }
        }

        // ── Top Processes (conditionally enabled) ──
        // NOTE: Top processes are collected at startup via collectTopProcessesOnce()
        // and via manual refresh button, NOT in the periodic timer loop.
        // Keep existing values to avoid re-collection on every tick.

        // ── Update published properties ──
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.cpu = cpuInfo
            self.sysInfo.uptime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            self.sysInfo.ips = ips
            self.sysInfo.displayResolutions = displayResolutions
            self.memory = MemoryInfo(
                totalGB: Double(memTotal) / 1024 / 1024 / 1024,
                usedGB: Double(usedMem) / 1024 / 1024 / 1024,
                availableGB: Double(availableMemBytes) / 1024 / 1024 / 1024,
                freeGB: Double(freeMemBytes) / 1024 / 1024 / 1024,
                percent: memPct,
                swapTotalGB: Double(swapTotal) / 1024 / 1024,
                swapUsedGB: Double(swapUsed) / 1024 / 1024,
                swapPercent: swapPct
            )
            self.gpu = GpuInfo(
                name: gpuName,
                vramMB: gpuVRAM,
                utilization: gpuUtil,
                chip: nil,
                utilizationHistory: histSlice
            )
            // ── Power via IOReport (with PowerEstimator fallback) ──
            let powerData: PowerData
            if IOReportReader.shared.isEnergyModelAvailable {
                powerData = IOReportReader.shared.readPower(cpuUsagePercent: cpuInfo.percent, gpuUsagePercent: Double(self.gpu.utilization ?? 0))
            } else {
                // Fallback: estimate from CPU/GPU utilization
                let cpuUsage = cpuInfo.percent
                let gpuUsage = Double(self.gpu.utilization ?? 0)
                powerData = PowerEstimator.shared.estimate(cpuUsagePercent: cpuUsage, gpuUsagePercent: gpuUsage)
            }

            // ── Temperature via IOHIDEventSystemClient (Apple Silicon, no root required) ──
            var cpuTemp: Double? = nil
            var gpuTemp: Double? = nil
            var ssdTemp: Double? = nil
            if ENABLE_TEMPERATURES {
                let hidData = IOHIDReader.shared.readTemperatures()
                cpuTemp = hidData.cpuDieTemp
                gpuTemp = hidData.gpuDieTemp
                // SSD temperature is stored in gpuDieTemp on Mac mini M4 (NAND sensor)
                ssdTemp = hidData.gpuDieTemp

                // MacBook Pro (isLaptop): IOHID sensors run ~20°C lower than actual
                // Apply offset only to CPU temp, SSD temp stays as-is
                if self.sysInfo.isLaptop, let hidCpu = cpuTemp {
                    cpuTemp = hidCpu + 20.0
                }


            }

            self.temps = TempInfo(
                cpuPowerMw: powerData.cpuMw,
                gpuPowerMw: powerData.gpuMw,
                boardPowerMw: powerData.ramMw + powerData.aneMw + powerData.pciMw,
                totalPowerMw: powerData.totalMw,
                cpuTempC: cpuTemp,
                gpuTempC: gpuTemp,
                ssdTempC: ssdTemp,
                thermalPressure: "Nominal",
                thermalLevel: 0
            )
            fputs("MiniPulse: published temps totalMw=\(powerData.totalMw)\n", stderr)
            self.battery = batteryInfo
            self.diskIO = DiskIOInfo(
                readMBs: diskReadBytes,
                writeMBs: diskWriteBytes,
                // lastDiskIO stores MB directly (not bytes), no conversion needed
                totalReadMB: Double(diskReadBytes),
                totalWriteMB: Double(diskWriteBytes)
            )
            self.network = NetworkInfo(
                totalSentMB: Double(totalSent) / 1024 / 1024,
                totalRecvMB: Double(totalRecv) / 1024 / 1024,
                sentMBs: max(0, sentMBs),
                recvMBs: max(0, recvMBs),
                perIface: perIface,
                knownIfaceNames: knownIfaceNames,
                netstatRaw: netStatOut
            )

            self.topCPU = Array(topCpuOut)
            self.topMem = Array(topMemOut)
            // USB & Bluetooth are updated separately via their own startup/event handlers
            self.devices = DeviceInfo(bluetooth: btDevices, usb: self.devices.usb)
        }
    }

    // MARK: - Per-core CPU via mach API

    private func getPerCoreCPU() -> [Double] {
        var numCPUs: natural_t = 0
        var cpuLoad: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0

        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUs, &cpuLoad, &numCpuInfo)
        guard result == KERN_SUCCESS, let load = cpuLoad else { return [] }

        var perCore: [Double] = []
        let cpuLoadInfoSize = Int32(CPU_STATE_MAX)

        for i in 0..<Int(numCPUs) {
            let offset = Int(cpuLoadInfoSize) * i
            let user = Double(load[offset + Int(CPU_STATE_USER)])
            let system = Double(load[offset + Int(CPU_STATE_SYSTEM)])
            let idle = Double(load[offset + Int(CPU_STATE_IDLE)])
            let nice = Double(load[offset + Int(CPU_STATE_NICE)])
            let total = user + system + idle + nice
            let used = user + system + nice
            perCore.append(total > 0 ? used / total * 100 : 0)
        }

        let size = vm_size_t(numCpuInfo) * vm_size_t(MemoryLayout<integer_t>.stride)
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: load), size)

        return perCore
    }

    // MARK: - Shell helpers

    private func run(_ cmd: String, args: [String] = [], timeout: TimeInterval = 5) -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: cmd)
        task.arguments = args
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = Pipe()

        do {
            try task.run()
            task.waitUntilExit()
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }

    private func extractVMStat(_ output: String, key: String) -> UInt64 {
        let pattern = "\(key):\\s+(\\d+)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: output, range: NSRange(output.startIndex..., in: output)),
              let range = Range(match.range(at: 1), in: output) else { return 0 }
        return UInt64(output[range]) ?? 0
    }

    private func parseMB(_ s: String) -> UInt64 {
        let numStr = s.filter { $0.isNumber || $0 == "." }
        return UInt64((Double(numStr) ?? 0) * 1024 * 1024)
    }

    // MARK: - Diagnostic Report

    func generateDiagnosticReport() -> DiagnosticReport {
        var report = DiagnosticReport()

        // Timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        report.generatedAt = formatter.string(from: Date())

        // System info
        report.hostname = sysInfo.hostname
        report.osVersion = sysInfo.osVersion
        report.hwModel = sysInfo.hwModel
        report.machineModelName = sysInfo.machineModelName
        report.isLaptop = sysInfo.isLaptop
        report.uptime = sysInfo.uptime

        // CPU
        report.cpu.percent = cpu.percent
        report.cpu.perCore = cpu.perCore
        report.cpu.physicalCores = cpu.physical
        report.cpu.logicalCores = cpu.logical
        report.cpu.freqCurrentMHz = cpu.freqCurrent
        report.cpu.freqMinMHz = cpu.freqMin
        report.cpu.freqMaxMHz = cpu.freqMax

        // Memory
        report.memory.totalGB = memory.totalGB
        report.memory.usedGB = memory.usedGB
        report.memory.availableGB = memory.availableGB
        report.memory.freeGB = memory.freeGB
        report.memory.percent = memory.percent
        report.memory.swapTotalGB = memory.swapTotalGB
        report.memory.swapUsedGB = memory.swapUsedGB
        report.memory.swapPercent = memory.swapPercent

        // Battery
        if let bat = battery {
            report.battery = DiagnosticReport.BatterySnapshot(
                hasBattery: true,
                percent: bat.percent,
                charging: bat.charging,
                onBattery: bat.onBattery,
                cycleCount: bat.cycleCount,
                maxCapacity: bat.maxCapacity,
                designCapacity: bat.designCapacity,
                healthPercent: bat.healthPercent,
                voltage: bat.voltage,
                temperature: bat.temperature,
                timeRemaining: bat.timeRemaining,
                pmsetOutput: run("/usr/bin/pmset", args: ["-g", "batt"]),
                systemProfilerOutput: run("/usr/sbin/system_profiler", args: ["SPPowerDataType", "-json"])
            )
        } else {
            report.battery.hasBattery = false
            report.battery.pmsetOutput = run("/usr/bin/pmset", args: ["-g", "batt"])
            report.battery.systemProfilerOutput = run("/usr/sbin/system_profiler", args: ["SPPowerDataType", "-json"])
        }

        // Disk
        for disk in disks {
            report.disk.append(DiagnosticReport.DiskSnapshot(
                name: disk.name,
                mountpoint: disk.mountpoint,
                totalGB: disk.totalGB,
                usedGB: disk.usedGB,
                freeGB: disk.freeGB,
                percent: disk.percent
            ))
        }

        // Network
        report.network.totalSentMB = network.totalSentMB
        report.network.totalRecvMB = network.totalRecvMB
        for iface in sysInfo.ips {
            report.network.interfaces[iface.iface] = iface.ip
        }

        // GPU
        report.gpu.hasGpu = !gpu.name.isEmpty
        report.gpu.name = gpu.name
        // GPU temperature from temps
        let gpuTemp = temps.gpuTempC ?? 0.0
        report.gpu.temperature = gpuTemp

        // Raw data sources
        report.rawData.pmsetRaw = run("/usr/bin/pmset", args: ["-g", "batt"])
        report.rawData.systemProfilerPowerRaw = run("/usr/sbin/system_profiler", args: ["SPPowerDataType", "-json"])
        report.rawData.systemProfilerHardwareRaw = run("/usr/sbin/system_profiler", args: ["SPHardwareDataType", "-json"])
        report.rawData.sysctlHwModel = run("/usr/sbin/sysctl", args: ["-n", "hw.model"])
        report.rawData.sysctlCpuInfo = run("/usr/sbin/sysctl", args: ["-n", "hw.ncpu", "machdep.cpu.brand_string"])
        report.rawData.sysctlMemInfo = run("/usr/sbin/sysctl", args: ["-n", "hw.memsize", "hw.pagesize"])

        return report
    }

    func saveDiagnosticReport(to url: URL) throws {
        let report = generateDiagnosticReport()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(report)
        try data.write(to: url)
    }
}

// MARK: - Diagnostic Report

struct DiagnosticReport: Codable {
    var generatedAt: String = ""
    var hostname: String = ""
    var osVersion: String = ""
    var hwModel: String = ""
    var machineModelName: String = ""
    var isLaptop: Bool = false

    var cpu: CPUSnapshot = CPUSnapshot()
    var memory: MemorySnapshot = MemorySnapshot()
    var battery: BatterySnapshot = BatterySnapshot()
    var disk: [DiskSnapshot] = []
    var network: NetworkSnapshot = NetworkSnapshot()
    var gpu: GpuSnapshot = GpuSnapshot()
    var uptime: String = ""

    // Raw data sources for debugging
    var rawData: RawDataSources = RawDataSources()

    struct CPUSnapshot: Codable {
        var percent: Double = 0
        var perCore: [Double] = []
        var physicalCores: Int = 0
        var logicalCores: Int = 0
        var freqCurrentMHz: Double = 0
        var freqMinMHz: Double = 0
        var freqMaxMHz: Double = 0
    }

    struct MemorySnapshot: Codable {
        var totalGB: Double = 0
        var usedGB: Double = 0
        var availableGB: Double = 0
        var freeGB: Double = 0
        var percent: Double = 0
        var swapTotalGB: Double = 0
        var swapUsedGB: Double = 0
        var swapPercent: Double = 0
    }

    struct BatterySnapshot: Codable {
        var hasBattery: Bool = false
        var percent: Int = 0
        var charging: Bool = false
        var onBattery: Bool = false
        var cycleCount: Int = 0
        var maxCapacity: Int = 0
        var designCapacity: Int = 0
        var healthPercent: Int = 0
        var voltage: Int = 0
        var temperature: Double = 0.0
        var timeRemaining: Int = 0
        var pmsetOutput: String = ""
        var systemProfilerOutput: String = ""
    }

    struct DiskSnapshot: Codable {
        var name: String = ""
        var mountpoint: String = ""
        var totalGB: Double = 0
        var usedGB: Double = 0
        var freeGB: Double = 0
        var percent: Double = 0
    }

    struct NetworkSnapshot: Codable {
        var totalSentMB: Double = 0
        var totalRecvMB: Double = 0
        var interfaces: [String: String] = [:]
    }

    struct GpuSnapshot: Codable {
        var name: String = ""
        var utilizationPercent: Double = 0
        var memoryUsedMB: Double = 0
        var memoryTotalMB: Double = 0
        var temperature: Double = 0.0
        var hasGpu: Bool = false
    }

    struct RawDataSources: Codable {
        var pmsetRaw: String = ""
        var systemProfilerPowerRaw: String = ""
        var systemProfilerHardwareRaw: String = ""
        var sysctlHwModel: String = ""
        var sysctlCpuInfo: String = ""
        var sysctlMemInfo: String = ""
    }
}

