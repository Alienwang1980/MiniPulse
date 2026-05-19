import SwiftUI

// MARK: - CardType

enum CardType: String, CaseIterable, Codable, Identifiable {
    case cpu
    case memory
    case gpu
    case power
    case battery
    case network
    case disk
    case bluetooth
    case usb
    case machineInfo
    case topCpu
    case topMem

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cpu: return "CPU"
        case .memory: return "内存"
        case .gpu: return "GPU"
        case .power: return "电源"
        case .battery: return "电池"
        case .network: return "网络"
        case .disk: return "磁盘"
        case .bluetooth: return "蓝牙"
        case .usb: return "USB"
        case .machineInfo: return "机器信息"
        case .topCpu: return "CPU 进程"
        case .topMem: return "内存进程"
        }
    }

    var iconName: String {
        switch self {
        case .cpu: return "cpu"
        case .memory: return "memorychip"
        case .gpu: return "rectangle.3.group"
        case .power: return "bolt.fill"
        case .battery: return "battery.100"
        case .network: return "network"
        case .disk: return "externaldrive.fill"
        case .bluetooth: return "dot.radiowaves.left.and.right"
        case .usb: return "cable.connector"
        case .machineInfo: return "info.circle.fill"
        case .topCpu: return "chart.bar.fill"
        case .topMem: return "chart.pie.fill"
        }
    }

    /// Default order when User has not customized
    static var defaultOrder: [CardType] {
        [.cpu, .memory, .gpu, .power, .battery, .network, .disk, .bluetooth, .usb, .machineInfo, .topCpu, .topMem]
    }
}

// MARK: - CardOrderManager (UserDefaults persistence)

private let cardOrderKey = "cardOrder"

extension UserDefaults {
    var cardOrder: [CardType] {
        get {
            guard let data = data(forKey: cardOrderKey),
                  let saved = try? JSONDecoder().decode([CardType].self, from: data),
                  saved.count == CardType.allCases.count else {
                return CardType.defaultOrder
            }
            return saved
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: cardOrderKey)
            }
        }
    }
}

// MARK: - CardOrderManager

@Observable
final class CardOrderManager {
    static let shared = CardOrderManager()

    private(set) var order: [CardType] = []

    private init() {
        order = UserDefaults.standard.cardOrder
    }

    func reset() {
        order = CardType.defaultOrder
        save()
    }

    func move(from source: IndexSet, to destination: Int) {
        order.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func moveItem(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              sourceIndex >= 0, sourceIndex < order.count,
              destinationIndex >= 0, destinationIndex < order.count else { return }
        let item = order.remove(at: sourceIndex)
        order.insert(item, at: destinationIndex)
        save()
    }

    private func save() {
        UserDefaults.standard.cardOrder = order
    }
}
