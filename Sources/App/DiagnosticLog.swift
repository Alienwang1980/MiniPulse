import Foundation

// MARK: - Shared Diagnostic Log

/// App bundle parent directory shared log file.
/// Written beside the .app bundle so it's always accessible.
private let logFileURL: URL = {
    let bundlePath = Bundle.main.bundlePath
    let parentDir = (bundlePath as NSString).deletingLastPathComponent
    return URL(fileURLWithPath: parentDir).appendingPathComponent("minipulse.log")
}()

/// Fallback path if sandbox blocks writing to the app parent directory.
private let logFileFallback: URL = {
    URL(fileURLWithPath: "/tmp/minipulse.log")
}()

/// Append a line to the diagnostic log.
func logToFile(_ msg: String) {
    let line = "\(Date().timeIntervalSince1970.formatted(.number.precision(.fractionLength(3)))) \(msg)\n"
    guard let data = line.data(using: .utf8) else { return }
    tryWrite(data, to: logFileURL) || tryWrite(data, to: logFileFallback)
}

private func tryWrite(_ data: Data, to url: URL) -> Bool {
    if let handle = try? FileHandle(forWritingTo: url) {
        _ = try? handle.seekToEnd()
        try? handle.write(contentsOf: data)
        try? handle.close()
        return true
    } else if (try? data.write(to: url)) != nil {
        return true
    }
    return false
}
