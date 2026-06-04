import SwiftUI

// MARK: - Host Manager (observable singleton)

/// Central manager for all known hosts (local + remote) and their per-host
/// card-visibility settings.
@Observable
final class HostManager {
    static let shared = HostManager()

    // ── Host list ────────────────────────────────────────────────────────────
    private(set) var hosts: [Host] = []

    /// Toggled each time the host list is modified, to force UI refresh.
    var hostListChanged = false

    /// `nil` = local machine; otherwise the `hostId` of the currently-selected host.
    var selectedHostId: String? = nil

    // ── Broadcast toggle ─────────────────────────────────────────────────────
    var broadcastingEnabled: Bool {
        didSet {
            UserDefaults.standard.set(broadcastingEnabled, forKey: "broadcastingEnabled")
            // Notify LANService
            if broadcastingEnabled {
                LANService.shared.resumeBroadcast()
            } else {
                LANService.shared.stopBroadcast()
            }
        }
    }

    // ── Init ─────────────────────────────────────────────────────────────────
    private init() {
        self.broadcastingEnabled = UserDefaults.standard.object(forKey: "broadcastingEnabled") as? Bool ?? true
    }

    // ── Local host management ────────────────────────────────────────────────
    /// Call once when the local SystemMonitor's data is ready.
    func setLocalHost(name: String, machine: String) {
        guard !hosts.contains(where: { $0.isLocal }) else { return }
        let host = Host(
            id: SystemMonitor.localHostId,
            name: name,
            machineModel: machine,
            isLocal: true,
            isOnline: true
        )
        hosts.insert(host, at: 0)
    }

    // ── Remote host management ───────────────────────────────────────────────
    /// Update an existing remote host or add a new one.
    func upsertRemote(from snapshot: RemoteSnapshot, hostname: String?, port: Int) {
        if let idx = hosts.firstIndex(where: { $0.id == snapshot.hostId }) {
            hosts[idx].name = snapshot.hostname
            hosts[idx].machineModel = snapshot.machineModel
            hosts[idx].lastSnapshot = snapshot
            hosts[idx].lastSeen = Date()
            hosts[idx].isOnline = true
            hosts[idx].serviceHostname = hostname
            hosts[idx].servicePort = port
        } else {
            let host = Host(
                id: snapshot.hostId,
                name: snapshot.hostname,
                machineModel: snapshot.machineModel,
                isLocal: false,
                isOnline: true,
                lastSnapshot: snapshot,
                lastSeen: Date(),
                serviceHostname: hostname,
                servicePort: port
            )
            hosts.append(host)
        }
        hostListChanged = true
        NotificationCenter.default.post(name: Notification.Name("com.hermes.minipulse.hostListChanged"), object: nil)
    }

    /// Mark hosts that haven't been seen in >15 seconds as offline.
    func checkTimeouts() {
        let deadline = Date().addingTimeInterval(-15)
        for i in hosts.indices where !hosts[i].isLocal {
            if let lastSeen = hosts[i].lastSeen, lastSeen < deadline {
                hosts[i].isOnline = false
            }
        }
    }

    /// Remove a remote host and clean up its stored preferences.
    func forgetHost(_ hostId: String) {
        if selectedHostId == hostId {
            selectedHostId = nil  // revert to local
        }
        let prefix = "hostCardVisibility_\(hostId)_"
        for key in UserDefaults.standard.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
            UserDefaults.standard.removeObject(forKey: key)
        }
        pollTasks[hostId]?.cancel()
        pollTasks.removeValue(forKey: hostId)
        hosts.removeAll { $0.id == hostId }
    }

    // ── Polling task references (held here so forgetHost can cancel them) ──
    var pollTasks: [String: Task<Void, Never>] = [:]

    // ── Helpers for ContentView ──────────────────────────────────────────────

    /// The snapshot of the currently selected host, or `nil` for the local machine.
    var selectedHostSnapshot: RemoteSnapshot? {
        guard let id = selectedHostId else { return nil }
        return hosts.first(where: { $0.id == id })?.lastSnapshot
    }

    /// Returns the card types that are visible for a given host.
    func activeCardTypes(for hostId: String) -> [CardType] {
        CardType.allCases.filter { isCardVisible($0, for: hostId) }
    }

    // ── Per-host card visibility (stored in UserDefaults) ───────────────────

    func isCardVisible(_ cardType: CardType, for hostId: String) -> Bool {
        let key = "hostCardVisibility_\(hostId)_\(cardType.rawValue)"
        return UserDefaults.standard.object(forKey: key) as? Bool ?? true
    }

    func setCardVisible(_ visible: Bool, for cardType: CardType, hostId: String) {
        let key = "hostCardVisibility_\(hostId)_\(cardType.rawValue)"
        UserDefaults.standard.set(visible, forKey: key)
    }
}
