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

                        WaterfallLayout(columnCount: max(1, min(4, Int(geo.size.width / 320))), spacing: 16.8) {
                            ForEach(CardOrderManager.shared.order, id: \.self) { cardType in
                                cardView(for: cardType)
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
        .frame(minWidth: 720, minHeight: 840)
        .background(Color.clear)
        .sheet(isPresented: $showSettings) {
            SettingsPanel(isPresented: $showSettings)
        }
        .sheet(isPresented: $showEditOrder) {
            EditOrderView(isPresented: $showEditOrder, isLaptop: monitor.sysInfo.isLaptop)
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

    @ViewBuilder
    private func cardView(for cardType: CardType) -> some View {
        switch cardType {
        case .cpu:
            CardContainer(isVisible: cpuVisible) {
                CpuCard(cpu: monitor.cpu, cpuTempC: monitor.temps.cpuTempC)
            }
        case .memory:
            CardContainer(isVisible: memVisible) {
                MemoryCard(mem: monitor.memory)
            }
        case .gpu:
            CardContainer(isVisible: gpuVisible) {
                GpuCard(gpu: monitor.gpu)
            }
        case .power:
            CardContainer(isVisible: powerVisible) {
                PowerCard(temps: monitor.temps, battery: monitor.battery, isLaptop: monitor.sysInfo.isLaptop)
            }
        case .battery:
            if monitor.sysInfo.isLaptop {
                CardContainer(isVisible: batteryVisible) {
                    BatteryCard(battery: monitor.battery, totalOperatingHours: monitor.battery?.totalOperatingHours ?? 0)
                }
            }
        case .network:
            CardContainer(isVisible: netVisible) {
                NetworkCard(net: monitor.network, ips: monitor.sysInfo.ips)
            }
        case .disk:
            CardContainer(isVisible: diskVisible) {
                DiskCard(disks: monitor.disks, diskIO: monitor.diskIO, ssdTempC: monitor.temps.ssdTempC)
            }
        case .bluetooth:
            CardContainer(isVisible: bluetoothVisible) {
                BluetoothCard(devices: monitor.devices)
            }
        case .usb:
            CardContainer(isVisible: usbVisible) {
                UsbCard(devices: monitor.devices)
            }
        case .machineInfo:
            CardContainer(isVisible: machineInfoVisible) {
                MachineInfoCard(sysInfo: monitor.sysInfo, gpu: monitor.gpu)
            }
        case .topCpu:
            CardContainer(isVisible: topCpuVisible) {
                TopCPUCard(topCPU: monitor.topCPU)
            }
        case .topMem:
            CardContainer(isVisible: topMemVisible) {
                TopMemCard(topMem: monitor.topMem)
            }
        }
    }
}
