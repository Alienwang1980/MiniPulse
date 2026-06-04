import Foundation

// MARK: - Remote Snapshot (LAN broadcast data model)

/// A Codable snapshot of all system metrics, sent over HTTP for LAN discovery.
/// All metric fields are Optional so that forward/backward compatibility is maintained
/// via `decodeIfPresent` — a newer sender may omit fields that an older receiver
/// doesn't know about, and vice‑versa.
struct RemoteSnapshot: Codable {
    let hostId: String
    let hostname: String
    let machineModel: String
    let osVersion: String
    let timestamp: TimeInterval   // Date.now.timeIntervalSince1970

    var cpu: CpuInfo?
    var memory: MemoryInfo?
    var gpu: GpuInfo?
    var temps: TempInfo?
    var battery: BatteryInfo?
    var disks: [DiskInfo]?
    var diskIO: DiskIOInfo?
    var network: NetworkInfo?
    var topCPU: [ProcessEntry]?
    var topMem: [ProcessEntry]?
    var devices: DeviceInfo?
    var sysInfo: SysInfo?
}
