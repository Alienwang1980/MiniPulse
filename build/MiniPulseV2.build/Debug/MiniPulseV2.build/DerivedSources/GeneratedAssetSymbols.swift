import Foundation
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "battery" asset catalog image resource.
    static let battery = DeveloperToolsSupport.ImageResource(name: "battery", bundle: resourceBundle)

    /// The "bluetooth" asset catalog image resource.
    static let bluetooth = DeveloperToolsSupport.ImageResource(name: "bluetooth", bundle: resourceBundle)

    /// The "cpu" asset catalog image resource.
    static let cpu = DeveloperToolsSupport.ImageResource(name: "cpu", bundle: resourceBundle)

    /// The "disk" asset catalog image resource.
    static let disk = DeveloperToolsSupport.ImageResource(name: "disk", bundle: resourceBundle)

    /// The "gpu" asset catalog image resource.
    static let gpu = DeveloperToolsSupport.ImageResource(name: "gpu", bundle: resourceBundle)

    /// The "logo_dark" asset catalog image resource.
    static let logoDark = DeveloperToolsSupport.ImageResource(name: "logo_dark", bundle: resourceBundle)

    /// The "logo_light" asset catalog image resource.
    static let logoLight = DeveloperToolsSupport.ImageResource(name: "logo_light", bundle: resourceBundle)

    /// The "logo_splash" asset catalog image resource.
    static let logoSplash = DeveloperToolsSupport.ImageResource(name: "logo_splash", bundle: resourceBundle)

    /// The "logo_splash_light" asset catalog image resource.
    static let logoSplashLight = DeveloperToolsSupport.ImageResource(name: "logo_splash_light", bundle: resourceBundle)

    /// The "machineInfo" asset catalog image resource.
    static let machineInfo = DeveloperToolsSupport.ImageResource(name: "machineInfo", bundle: resourceBundle)

    /// The "memory" asset catalog image resource.
    static let memory = DeveloperToolsSupport.ImageResource(name: "memory", bundle: resourceBundle)

    /// The "network" asset catalog image resource.
    static let network = DeveloperToolsSupport.ImageResource(name: "network", bundle: resourceBundle)

    /// The "power" asset catalog image resource.
    static let power = DeveloperToolsSupport.ImageResource(name: "power", bundle: resourceBundle)

    /// The "topCpu" asset catalog image resource.
    static let topCpu = DeveloperToolsSupport.ImageResource(name: "topCpu", bundle: resourceBundle)

    /// The "topMem" asset catalog image resource.
    static let topMem = DeveloperToolsSupport.ImageResource(name: "topMem", bundle: resourceBundle)

    /// The "usb" asset catalog image resource.
    static let usb = DeveloperToolsSupport.ImageResource(name: "usb", bundle: resourceBundle)

}

