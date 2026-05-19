import AppKit
import CoreText

// Register bundled fonts at launch
func registerBundledFonts() {
    guard let resourcesURL = Bundle.main.resourceURL else { return }
    let fontNames = [
        "Silkscreen-Regular",
        "Silkscreen-Bold",
        "VT323-Regular",
        "PressStart2P-Regular"
    ]
    for name in fontNames {
        let url = resourcesURL.appendingPathComponent("\(name).ttf")
        guard FileManager.default.fileExists(atPath: url.path),
              let fontData = try? Data(contentsOf: url),
              let dataProvider = CGDataProvider(data: fontData as CFData),
              let cgFont = CGFont(dataProvider) else {
            print("[Fonts] Load failed: \(name)")
            continue
        }
        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(cgFont, &error) {
            print("[Fonts] Registered: \(name)")
        } else {
            if let err = error?.takeRetainedValue() {
                print("[Fonts] Failed: \(name) — \(err)")
            }
        }
    }
}

registerBundledFonts()

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
