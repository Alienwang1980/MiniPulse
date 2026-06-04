import Foundation

// MARK: - Host (local or remote)

/// Represents a single machine running MiniPulse that this instance knows about.
/// The local machine is represented as a `Host` with `isLocal = true`; remote
/// machines discovered via Bonjour are `isLocal = false`.
struct Host: Identifiable, Equatable {
    let id: String                 // hostId from RemoteSnapshot or SystemMonitor.localHostId
    var name: String               // Display name (hostname)
    var machineModel: String
    var isLocal: Bool
    var isOnline: Bool
    var lastSnapshot: RemoteSnapshot?
    var lastSeen: Date?
    var serviceHostname: String?   // Bonjour-resolved hostname for HTTP polling
    var servicePort: Int?          // Bonjour-resolved port

    /// Equality is based solely on the stable host `id` so that SwiftUI can
    /// diff host lists without comparing potentially-large snapshot data.
    static func == (lhs: Host, rhs: Host) -> Bool {
        lhs.id == rhs.id
    }
}
