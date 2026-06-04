import Foundation
import Network
import AppKit

// MARK: - LAN Service (HTTP server + Bonjour broadcast + discovery)

/// Manages all LAN networking for MiniPulse:
/// - HTTP server that serves the local `RemoteSnapshot` as JSON
/// - Bonjour (mDNS) publishing so other instances can discover this machine
/// - Bonjour browsing to discover remote instances and pull their snapshots
///
/// All `NetService` / `NetServiceBrowser` operations **must** be done on the main
/// dispatch queue because they rely on the main thread's RunLoop.
final class LANService: NSObject {
    static let shared = LANService()

    // ── Port management ──────────────────────────────────────────────────────
    private let defaultPorts: [UInt16] = [8765, 8766, 8767, 8768, 8769, 8770]
    private var activePort: UInt16 = 8765

    // ── Components ───────────────────────────────────────────────────────────
    private var listener: NWListener?
    private var netService: NetService?
    private var browser: NetServiceBrowser?

    // ── Callback ──────────────────────────────────────────────────────────────
    /// Called by the HTTP handler to get the latest local snapshot.
    /// Set during initialisation from `ContentView.onAppear`.
    var snapshotProvider: (() -> RemoteSnapshot?)?

    // ── Internal state ────────────────────────────────────────────────────────
    private var isBroadcasting = false
    // Per-remote-host polling tasks (keyed by hostId)
    private var pollTasks: [String: Task<Void, Never>] = [:]
    // Services we've already resolved (keyed by NetService hash)
    private var resolvingServices = Set<String>()

    // ── Public API ────────────────────────────────────────────────────────────

    /// Start HTTP server + Bonjour publishing + discovery.
    /// Must be called on the **main thread** (NetService requirement).
    func start() {
        DispatchQueue.main.async { [weak self] in
            self?._start()
        }
    }

    private func _start() {
        guard let port = findAvailablePort(from: defaultPorts) else {
            print("[LANService] No available port, disabling broadcast")
            return
        }
        activePort = port
        startListener(port: port)
        startBroadcasting(port: port)
        startDiscovery()
    }

    /// Stop HTTP server + Bonjour publishing (but keep browsing).
    /// Browsing is **not** stopped so we can still see remote instances.
    func stopBroadcast() {
        guard isBroadcasting else { return }
        isBroadcasting = false
        listener?.cancel()
        listener = nil
        netService?.stop()
        netService = nil
        print("[LANService] Broadcast stopped")
    }

    /// Restart HTTP server + Bonjour publishing (after a prior stop).
    func resumeBroadcast() {
        guard !isBroadcasting else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.startListener(port: self.activePort)
            self.startBroadcasting(port: self.activePort)
        }
    }

    /// Called periodically (every ~5s) by the polling loop to mark stale hosts offline.
    func checkTimeouts() {
        HostManager.shared.checkTimeouts()
    }

    // ── Port scan ────────────────────────────────────────────────────────────

    private func findAvailablePort(from ports: [UInt16]) -> UInt16? {
        for port in ports {
            let sock = Darwin.socket(AF_INET, SOCK_STREAM, 0)
            guard sock >= 0 else { continue }

            var reuse = 1
            setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int>.size))

            var addr = sockaddr_in()
            addr.sin_family = sa_family_t(AF_INET)
            addr.sin_port = CFSwapInt16HostToBig(port)
            addr.sin_addr.s_addr = INADDR_ANY

            let bindResult = withUnsafePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    Darwin.bind(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
            Darwin.close(sock)

            if bindResult == 0 {
                return port  // available
            }
        }
        return nil
    }

    // ── HTTP server (NWListener) ─────────────────────────────────────────────

    private func startListener(port: UInt16) {
        let params = NWParameters(tls: nil, tcp: .init())
        params.allowLocalEndpointReuse = true

        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            print("[LANService] Invalid port: \(port)")
            return
        }

        do {
            listener = try NWListener(using: params, on: nwPort)
        } catch {
            print("[LANService] Listener start failed on port \(port): \(error)")
            return
        }

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }

        listener?.start(queue: .main)
        isBroadcasting = true
        print("[LANService] HTTP server listening on :\(port)")
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .main)

        var buffer = Data()
        // Accumulate data until we see \r\n\r\n (end of HTTP headers)
        func receive() {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
                guard let self = self else { return }

                if let data = data, !data.isEmpty {
                    buffer.append(data)
                }

                // Look for end of HTTP headers
                if let headerRange = buffer.range(of: "\r\n\r\n".data(using: .utf8)!) {
                    let headerData = buffer[..<headerRange.lowerBound]
                    let bodyStart = headerRange.upperBound
                    let _ = buffer[bodyStart...]  // body (unused for GET)
                    self.processHTTPRequest(headerData: headerData, connection: connection)
                    buffer.removeAll()
                } else if isComplete || error != nil {
                    // Incomplete request — close
                    connection.cancel()
                    buffer.removeAll()
                } else {
                    // Need more data
                    receive()
                }
            }
        }
        receive()
    }

    private func processHTTPRequest(headerData: Data, connection: NWConnection) {
        guard let headerString = String(data: headerData, encoding: .utf8) else {
            sendResponse(connection, status: 400, body: "Bad Request")
            return
        }

        let lines = headerString.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            sendResponse(connection, status: 400, body: "Bad Request")
            return
        }

        let parts = requestLine.components(separatedBy: " ")
        guard parts.count >= 2, parts[0] == "GET" else {
            sendResponse(connection, status: 405, body: "Method Not Allowed")
            return
        }

        let path = parts[1]
        switch path {
        case "/api/v1/snapshot":
            handleSnapshotRequest(connection: connection)
        case "/api/v1/ping":
            sendResponse(connection, status: 200, body: #"{"status":"ok"}"#)
        default:
            sendResponse(connection, status: 404, body: "Not Found")
        }
    }

    private func handleSnapshotRequest(connection: NWConnection) {
        guard let snapshot = snapshotProvider?() else {
            sendResponse(connection, status: 503, body: "Service Unavailable")
            return
        }

        do {
            let data = try JSONEncoder().encode(snapshot)
            sendResponse(connection, status: 200, contentType: "application/json", bodyData: data)
        } catch {
            print("[LANService] Snapshot encoding failed: \(error)")
            sendResponse(connection, status: 500, body: "Internal Server Error")
        }
    }

    private func sendResponse(_ connection: NWConnection,
                               status: Int,
                               contentType: String = "text/plain",
                               body: String) {
        sendResponse(connection, status: status, contentType: contentType, bodyData: body.data(using: .utf8) ?? Data())
    }

    private func sendResponse(_ connection: NWConnection,
                               status: Int,
                               contentType: String = "text/plain",
                               bodyData: Data) {
        let statusText: String
        switch status {
        case 200: statusText = "OK"
        case 400: statusText = "Bad Request"
        case 404: statusText = "Not Found"
        case 405: statusText = "Method Not Allowed"
        case 500: statusText = "Internal Server Error"
        case 503: statusText = "Service Unavailable"
        default:  statusText = ""
        }

        let header = "HTTP/1.1 \(status) \(statusText)\r\n" +
                     "Content-Type: \(contentType)\r\n" +
                     "Content-Length: \(bodyData.count)\r\n" +
                     "Connection: close\r\n" +
                     "\r\n"

        let responseData = header.data(using: .utf8)! + bodyData
        connection.send(content: responseData, completion: .contentProcessed({ _ in
            connection.cancel()
        }))
    }

    // ── Bonjour publishing ───────────────────────────────────────────────────

    private func startBroadcasting(port: UInt16) {
        let serviceName = "\(ProcessInfo.processInfo.hostName)-\(port)"
        let bigEndianPort = CFSwapInt16HostToBig(port)

        netService = NetService(domain: "local.",
                                type: "_minipulse._tcp",
                                name: serviceName,
                                port: Int32(bigEndianPort))
        netService?.delegate = self
        netService?.publish()
        print("[LANService] Bonjour publishing as \(serviceName) on port \(port)")
    }

    // ── Bonjour discovery ────────────────────────────────────────────────────

    private func startDiscovery() {
        browser = NetServiceBrowser()
        browser?.delegate = self
        browser?.searchForServices(ofType: "_minipulse._tcp", inDomain: "local.")
        print("[LANService] Bonjour discovery started")
    }

    // ── Remote polling ───────────────────────────────────────────────────────

    /// Start polling a remote host every 5 seconds.
    private func startPolling(hostname: String, port: Int, hostId: String) {
        // Cancel any existing poll for this host
        pollTasks[hostId]?.cancel()

        let task = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { break }
                await self.fetchSnapshot(hostname: hostname, port: port, hostId: hostId)
                try? await Task.sleep(nanoseconds: 5_000_000_000)  // 5 seconds
            }
        }
        pollTasks[hostId] = task
    }

    private func fetchSnapshot(hostname: String, port: Int, hostId: String) async {
        guard let url = URL(string: "http://\(hostname):\(port)/api/v1/snapshot") else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { return }

            let snapshot = try JSONDecoder().decode(RemoteSnapshot.self, from: data)

            // Skip self-discovery
            guard snapshot.hostId != SystemMonitor.localHostId else { return }

            await MainActor.run {
                HostManager.shared.upsertRemote(from: snapshot, hostname: hostname, port: port)
                // After each successful poll batch, check timeouts
                self.checkTimeouts()
            }
        } catch {
            // Network error — host may be offline; timeout check will handle it
            // Just ensure we still call checkTimeouts so offline detection isn't delayed
            await MainActor.run {
                self.checkTimeouts()
            }
        }
    }
}

// MARK: - NetServiceDelegate

extension LANService: NetServiceDelegate {
    func netServiceDidPublish(_ sender: NetService) {
        print("[LANService] Bonjour published: \(sender.name)")
    }

    func netService(_ sender: NetService, didNotPublish errorDict: [String: NSNumber]) {
        print("[LANService] Bonjour publish failed: \(errorDict)")
    }
}

// MARK: - NetServiceBrowserDelegate

extension LANService: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser,
                           didFind service: NetService,
                           moreComing: Bool) {
        let serviceHash = "\(service.name)-\(service.type)-\(service.domain)"
        guard !resolvingServices.contains(serviceHash) else { return }
        resolvingServices.insert(serviceHash)

        service.delegate = self

        // Resolve with a short timeout; on failure we simply ignore this service
        // until the next Bonjour announcement.
        service.resolve(withTimeout: 5)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser,
                           didRemove service: NetService,
                           moreComing: Bool) {
        let serviceHash = "\(service.name)-\(service.type)-\(service.domain)"
        resolvingServices.remove(serviceHash)
        // The host will be marked offline by the 15-second timeout in HostManager.
        // We don't remove it immediately because the user may still want to see
        // stale data while the host is temporarily unreachable.
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
        print("[LANService] Bonjour search failed: \(errorDict)")
    }
}

// MARK: - NetServiceDelegate (resolve callback)

extension LANService {
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let hostname = sender.hostName else {
            print("[LANService] Resolved but no hostname for \(sender.name)")
            return
        }
        let port = sender.port  // already in host byte order (converted by NetService)
        let hostId = "resolved-\(sender.name)"  // temporary; real hostId comes from snapshot

        print("[LANService] Resolved \(sender.name) → \(hostname):\(port)")
        startPolling(hostname: hostname, port: Int(port), hostId: hostId)
    }

    func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
        print("[LANService] Resolve failed for \(sender.name): \(errorDict)")
        let serviceHash = "\(sender.name)-\(sender.type)-\(sender.domain)"
        resolvingServices.remove(serviceHash)
    }
}
