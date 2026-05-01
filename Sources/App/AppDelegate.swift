import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1100, height: 760),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "MiniPulse"
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.minSize = NSSize(width: 800, height: 700)
        window.backgroundColor = NSColor(red: 6/255, green: 10/255, blue: 20/255, alpha: 1.0)

        NSApplication.shared.setActivationPolicy(.regular)

        setupMainMenu()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    private func setupMainMenu() {
        let mainMenu = NSMenu()

        // Application menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        appMenu.addItem(withTitle: "About MiniPulse", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit MiniPulse", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        // File menu
        let fileMenuItem = NSMenuItem()
        mainMenu.addItem(fileMenuItem)
        let fileMenu = NSMenu(title: "File")
        fileMenuItem.submenu = fileMenu
        fileMenu.addItem(withTitle: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")

        // Edit menu
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        // Window menu
        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: "Window")
        windowMenuItem.submenu = windowMenu
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")

        // Help menu
        let helpMenuItem = NSMenuItem()
        mainMenu.addItem(helpMenuItem)
        let helpMenu = NSMenu(title: "Help")
        helpMenuItem.submenu = helpMenu

        let diagnosticItem = NSMenuItem(
            title: "Generate Diagnostic Report",
            action: #selector(generateDiagnosticReportMenuAction),
            keyEquivalent: ""
        )
        diagnosticItem.keyEquivalentModifierMask = [.command, .shift]
        diagnosticItem.target = self
        helpMenu.addItem(diagnosticItem)

        NSApplication.shared.mainMenu = mainMenu
    }

    @objc private func generateDiagnosticReportMenuAction() {
        // Post a notification that the ContentView's SystemMonitor will listen to
        // We use the shared NotificationCenter to broadcast
        DistributedNotificationCenter.default().postNotificationName(
            NSNotification.Name("com.hermes.minipulse.generateDiagnostic"),
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )

        // Also post to the standard NotificationCenter (for same-app-process)
        NotificationCenter.default.post(
            name: Notification.Name("com.hermes.minipulse.generateDiagnostic"),
            object: nil
        )
    }

    func showDiagnosticResult(path: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let alert = NSAlert()
            alert.messageText = "Diagnostic Report Generated"
            alert.informativeText = "Report saved to:\n\(path)\n\nPlease share this file with the developer for analysis."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Show in Finder")
            alert.addButton(withTitle: "OK")

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                let url = URL(fileURLWithPath: path)
                let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
                NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: desktop.path)
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
