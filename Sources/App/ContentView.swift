import SwiftUI
import AppKit

// MARK: - Main ContentView

struct ContentView: View {
    @StateObject private var monitor = SystemMonitor()
    @Environment(\.colorScheme) private var colorScheme

    @State private var showSplash = true
    @State private var cardsAppeared = false
    @State private var cpuVisible = false
    @State private var showSettings = false
    @State private var showEditOrder = false
    @State private var memVisible = false
    @State private var gpuVisible = false
    @State private var powerVisible = false
    @State private var batteryVisible = false
    @State private var netVisible = false
    @State private var diskVisible = false
    @State private var bluetoothVisible = false
    @State private var usbVisible = false
    @State private var machineInfoVisible = false
    @State private var topCpuVisible = false
    @State private var topMemVisible = false

    @State private var hostManager = HostManager.shared
    @State private var showHostSettings = false

    var body: some View {
        ZStack(alignment: .top) {
            // Background: solid neutral gray
            Rectangle().fill(AppTheme.shared.surface)

            // 8-bit mode: gradient wash overlay
            if AppTheme.shared.isEightBit {
                LinearGradient(
                    colors: [
                        Color(hex: "E8A598").opacity(0.10),
                        Color(hex: "8ED8BE").opacity(0.06),
                        Color(hex: "9DD3E8").opacity(0.08),
                        Color(hex: "C4B0E8").opacity(0.06),
                        Color(hex: "E8A598").opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(9999)
            }

            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 120)

                        WaterfallLayout(columnCount: max(1, min(4, Int(geo.size.width / 300))), spacing: 16.8) {
                            if hostManager.hosts.count > 1 {
                                hostTabBar
                            }
                            if activeTypes.isEmpty, selectedHostId != nil {
                                emptyCardPlaceholder
                            } else {
                                ForEach(activeTypes, id: \.self) { cardType in
                                    cardView(for: cardType)
                                }
                            }
                        }
                        .padding(24)

                        Color.clear.frame(height: 72)
                    }
                }
                .background(AppTheme.shared.surface.opacity(0.0))

                VStack {
                    Spacer()
                    FooterView(sysInfo: monitor.sysInfo)
                }
            }

            HeaderView(sysInfo: monitor.sysInfo, cpu: monitor.cpu, temps: monitor.temps, showSettings: $showSettings, showEditOrder: $showEditOrder)
        }
        .frame(minWidth: 480, minHeight: 540)
        .background(Color.clear)
        .overlay(alignment: .top) {
            if showSettings {
                ZStack {
                    Color.black.opacity(0.6)
                        .contentShape(Rectangle())
                        .onTapGesture { showSettings = false }
                        .ignoresSafeArea()

                    SettingsPanel(isPresented: $showSettings)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.25), value: showSettings)
            }
        }
        .overlay(alignment: .top) {
            if showEditOrder {
                ZStack {
                    Color.black.opacity(0.6)
                        .contentShape(Rectangle())
                        .onTapGesture { showEditOrder = false }
                        .ignoresSafeArea()

                    EditOrderView(isPresented: $showEditOrder, isLaptop: monitor.sysInfo.isLaptop)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.25), value: showEditOrder)
            }
        }
        .onAppear {
            // Inject system colorScheme so theme follows OS preference initially
            AppTheme.shared.systemColorScheme = colorScheme
            // Start monitor and listen for diagnostic requests
            monitor.start()
            NotificationCenter.default.addObserver(
                forName: Notification.Name("com.hermes.minipulse.generateDiagnostic"),
                object: nil,
                queue: .main
            ) { [self] _ in
                generateAndSaveDiagnosticReport()
            }
        }
        .onChange(of: colorScheme) { _, newScheme in
            AppTheme.shared.systemColorScheme = newScheme
        }
        .onChange(of: monitor.dataReady) { _, ready in
            if ready {
                dismissSplashAndShowCards()
            }
        }
    }

    private func dismissSplashAndShowCards() {
        withAnimation(.easeOut(duration: 0.8)) {
            showSplash = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { cpuVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { memVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { gpuVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { powerVisible = true }
        if monitor.sysInfo.isLaptop {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) { batteryVisible = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { netVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { diskVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) { bluetoothVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { usbVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { machineInfoVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { topCpuVisible = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { topMemVisible = true }
    }

    private func generateAndSaveDiagnosticReport() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let timestamp = formatter.string(from: Date())
        let hostname = monitor.sysInfo.hostname.isEmpty ? "unknown" : monitor.sysInfo.hostname
        let filename = "MiniPulse-Diagnostic-\(hostname)-\(timestamp).json"

        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let fileURL = desktopURL.appendingPathComponent(filename)

        do {
            try monitor.saveDiagnosticReport(to: fileURL)

            let alert = NSAlert()
            alert.messageText = "Diagnostic Report Generated"
            alert.informativeText = "Report saved to:\n\(fileURL.path)\n\nPlease share this file with the developer for analysis."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Show in Finder")
            alert.addButton(withTitle: "OK")

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: desktopURL.path)
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Failed to Generate Report"
            alert.informativeText = "Error: \(error.localizedDescription)"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    private var selectedHostId: String? {
        hostManager.selectedHostId
    }

    /// Card types visible for the currently selected host (or all, for local)
    private var activeTypes: [CardType] {
        if let hostId = selectedHostId {
            hostManager.activeCardTypes(for: hostId)
        } else {
            CardOrderManager.shared.order
        }
    }

    // MARK: - Host Tab Bar

    @ViewBuilder
    private var hostTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(hostManager.hosts) { host in
                    Button(action: { selectHost(host) }) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(host.isOnline ? Color.green : Color.red)
                                .frame(width: 6, height: 6)
                            Text(host.isLocal ? "● 本机 (\(host.name))" : host.name)
                                .font(PixelFont.eightBit(size: 12))
                                .foregroundColor(host.id == selectedHostId
                                    ? AppTheme.shared.accent
                                    : AppTheme.shared.muted)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            host.id == selectedHostId
                                ? AppTheme.shared.accent.opacity(0.15)
                                : AppTheme.shared.card
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 8)
    }

    /// Switch to the given host, skipping card fade-in animations.
    private func selectHost(_ host: Host) {
        hostManager.selectedHostId = host.isLocal ? nil : host.id
        // Bypass card fade-in animations
        cpuVisible = true; memVisible = true; gpuVisible = true
        powerVisible = true; batteryVisible = true; netVisible = true
        diskVisible = true; bluetoothVisible = true; usbVisible = true
        machineInfoVisible = true; topCpuVisible = true; topMemVisible = true
    }

    // MARK: - Empty placeholder

    private var emptyCardPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "eye.slash")
                .font(.system(size: 32))
                .foregroundColor(AppTheme.shared.muted.opacity(0.5))
            Text("该主机所有卡片已隐藏")
                .font(PixelFont.eightBit(size: 13))
                .foregroundColor(AppTheme.shared.muted)
            Text("在设置 → 局域网管理中开启")
                .font(PixelFont.eightBit(size: 11))
                .foregroundColor(AppTheme.shared.muted.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Card rendering

    @ViewBuilder
    private func cardView(for cardType: CardType) -> some View {
        let isLocal = selectedHostId == nil
        let snap = hostManager.selectedHostSnapshot

        switch cardType {
        case .cpu:
            if isLocal {
                CardContainer(isVisible: cpuVisible) {
                    CpuCard(cpu: monitor.cpu, cpuTempC: monitor.temps.cpuTempC)
                }
            } else if let s = snap {
                CardContainer(isVisible: cpuVisible) {
                    CpuCard(cpu: s.cpu ?? CpuInfo(), cpuTempC: s.temps?.cpuTempC)
                }
            }
        case .memory:
            if isLocal {
                CardContainer(isVisible: memVisible) {
                    MemoryCard(mem: monitor.memory)
                }
            } else if let s = snap {
                CardContainer(isVisible: memVisible) {
                    MemoryCard(mem: s.memory ?? MemoryInfo())
                }
            }
        case .gpu:
            if isLocal {
                CardContainer(isVisible: gpuVisible) {
                    GpuCard(gpu: monitor.gpu)
                }
            } else if let s = snap {
                CardContainer(isVisible: gpuVisible) {
                    GpuCard(gpu: s.gpu ?? GpuInfo())
                }
            }
        case .power:
            if isLocal {
                CardContainer(isVisible: powerVisible) {
                    PowerCard(temps: monitor.temps, battery: monitor.battery, isLaptop: monitor.sysInfo.isLaptop)
                }
            } else if let s = snap {
                CardContainer(isVisible: powerVisible) {
                    PowerCard(temps: s.temps ?? TempInfo(), battery: s.battery, isLaptop: false)
                }
            }
        case .battery:
            if isLocal {
                if monitor.sysInfo.isLaptop {
                    CardContainer(isVisible: batteryVisible) {
                        BatteryCard(battery: monitor.battery, totalOperatingHours: monitor.battery?.totalOperatingHours ?? 0)
                    }
                }
            } else if let s = snap, s.battery != nil {
                CardContainer(isVisible: batteryVisible) {
                    BatteryCard(battery: s.battery, totalOperatingHours: s.battery?.totalOperatingHours ?? 0)
                }
            }
        case .network:
            if isLocal {
                CardContainer(isVisible: netVisible) {
                    NetworkCard(net: monitor.network, ips: monitor.sysInfo.ips)
                }
            } else if let s = snap {
                CardContainer(isVisible: netVisible) {
                    NetworkCard(net: s.network ?? NetworkInfo(), ips: s.sysInfo?.ips ?? [])
                }
            }
        case .disk:
            if isLocal {
                CardContainer(isVisible: diskVisible) {
                    DiskCard(disks: monitor.disks, diskIO: monitor.diskIO, ssdTempC: monitor.temps.ssdTempC)
                }
            } else if let s = snap {
                CardContainer(isVisible: diskVisible) {
                    DiskCard(disks: s.disks ?? [], diskIO: s.diskIO ?? DiskIOInfo(), ssdTempC: s.temps?.ssdTempC)
                }
            }
        case .bluetooth:
            if isLocal {
                CardContainer(isVisible: bluetoothVisible) {
                    BluetoothCard(devices: monitor.devices)
                }
            } else if let s = snap {
                CardContainer(isVisible: bluetoothVisible) {
                    BluetoothCard(devices: s.devices ?? DeviceInfo())
                }
            }
        case .usb:
            if isLocal {
                CardContainer(isVisible: usbVisible) {
                    UsbCard(devices: monitor.devices)
                }
            } else if let s = snap {
                CardContainer(isVisible: usbVisible) {
                    UsbCard(devices: s.devices ?? DeviceInfo())
                }
            }
        case .machineInfo:
            if isLocal {
                CardContainer(isVisible: machineInfoVisible) {
                    MachineInfoCard(sysInfo: monitor.sysInfo, gpu: monitor.gpu)
                }
            } else if let s = snap {
                CardContainer(isVisible: machineInfoVisible) {
                    MachineInfoCard(sysInfo: s.sysInfo ?? SysInfo(), gpu: s.gpu ?? GpuInfo())
                }
            }
        case .topCpu:
            if isLocal {
                CardContainer(isVisible: topCpuVisible) {
                    TopCPUCard(topCPU: monitor.topCPU)
                }
            } else if let s = snap {
                CardContainer(isVisible: topCpuVisible) {
                    TopCPUCard(topCPU: s.topCPU ?? [])
                }
            }
        case .topMem:
            if isLocal {
                CardContainer(isVisible: topMemVisible) {
                    TopMemCard(topMem: monitor.topMem)
                }
            } else if let s = snap {
                CardContainer(isVisible: topMemVisible) {
                    TopMemCard(topMem: s.topMem ?? [])
                }
            }
        }
    }
}
