//
//  SMC.swift
//  MiniPulse
//
//  Adapted from Stats.app (MIT License, github.com/exelban/stats)
//

import Foundation
import IOKit

// MARK: - SMC Data Types

internal enum SMCDataType: String {
    case UI8 = "ui8 "
    case UI16 = "ui16"
    case UI32 = "ui32"
    case SP1E = "sp1e"
    case SP3C = "sp3c"
    case SP4B = "sp4b"
    case SP5A = "sp5a"
    case SP69 = "sp69"
    case SP78 = "sp78"
    case SP87 = "sp87"
    case SP96 = "sp96"
    case SPB4 = "spb4"
    case SPF0 = "spf0"
    case FLT = "flt "
    case FPE2 = "fpe2"
}

internal enum SMCKeys: UInt8 {
    case kernelIndex = 2
    case readBytes = 5
    case writeBytes = 6
    case readIndex = 8
    case readKeyInfo = 9
}

// MARK: - SMC Structures

internal struct SMCKeyData_t {
    typealias SMCBytes_t = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                            UInt8, UInt8, UInt8, UInt8)

    struct keyInfo_t {
        var dataSize: IOByteCount32 = 0
        var dataType: UInt32 = 0
        var dataAttributes: UInt8 = 0
    }

    var key: UInt32 = 0
    var vers = vers_t()
    var pLimitData = LimitData_t()
    var keyInfo = keyInfo_t()
    var padding: UInt16 = 0
    var result: UInt8 = 0
    var status: UInt8 = 0
    var data8: UInt8 = 0
    var data32: UInt32 = 0
    var bytes: SMCBytes_t = (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                             UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                             UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                             UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                             UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
                             UInt8(0), UInt8(0))

    struct vers_t {
        var major: CUnsignedChar = 0
        var minor: CUnsignedChar = 0
        var build: CUnsignedChar = 0
        var reserved: CUnsignedChar = 0
        var release: CUnsignedShort = 0
    }

    struct LimitData_t {
        var version: UInt16 = 0
        var length: UInt16 = 0
        var cpuPLimit: UInt32 = 0
        var gpuPLimit: UInt32 = 0
        var memPLimit: UInt32 = 0
    }
}

internal struct SMCVal_t {
    var key: String
    var dataSize: UInt32 = 0
    var dataType: String = ""
    var bytes: [UInt8] = Array(repeating: 0, count: 32)

    init(_ key: String) {
        self.key = key
    }
}

// MARK: - FourCharCode extensions

extension FourCharCode {
    init(fromString str: String) {
        precondition(str.count == 4)
        self = str.utf8.reduce(0) { sum, character in
            return sum << 8 | UInt32(character)
        }
    }

    func toString() -> String {
        return String(describing: UnicodeScalar(self >> 24 & 0xff)!) +
               String(describing: UnicodeScalar(self >> 16 & 0xff)!) +
               String(describing: UnicodeScalar(self >> 8  & 0xff)!) +
               String(describing: UnicodeScalar(self       & 0xff)!)
    }
}

// MARK: - UInt16/UInt32 extensions

extension UInt16 {
    init(bytes: (UInt8, UInt8)) {
        self = UInt16(bytes.0) << 8 | UInt16(bytes.1)
    }
}

extension UInt32 {
    init(bytes: (UInt8, UInt8, UInt8, UInt8)) {
        self = UInt32(bytes.0) << 24 | UInt32(bytes.1) << 16 | UInt32(bytes.2) << 8 | UInt32(bytes.3)
    }
}

// FPE2 format: fixed-point 14.2
extension Int {
    init(fromFPE2 bytes: (UInt8, UInt8)) {
        self = (Int(bytes.0) << 6) + (Int(bytes.1) >> 2)
    }
}

// MARK: - SMC Reader

public class SMCReader {
    public static let shared = SMCReader()

    private var conn: io_connect_t = 0
    private var isConnected: Bool = false

    private init() {}

    public func connect() -> Bool {
        guard !isConnected else { return true }

        var result: kern_return_t
        var iterator: io_iterator_t = 0

        let matchingDictionary: CFMutableDictionary = IOServiceMatching("AppleSMC")
        result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDictionary, &iterator)
        if result != kIOReturnSuccess {
            print("SMC: IOServiceGetMatchingServices failed: \(String(cString: mach_error_string(result), encoding: .ascii) ?? "unknown")")
            return false
        }

        let device = IOIteratorNext(iterator)
        IOObjectRelease(iterator)

        if device == 0 {
            print("SMC: no AppleSMC device found")
            return false
        }

        // type=0: open for reading (no root required for most keys)
        result = IOServiceOpen(device, mach_task_self_, 0, &conn)
        IOObjectRelease(device)

        if result != kIOReturnSuccess {
            print("SMC: IOServiceOpen failed: \(String(cString: mach_error_string(result), encoding: .ascii) ?? "unknown")")
            return false
        }

        isConnected = true
        print("SMC: connected successfully (conn=\(conn))")
        return true
    }

    public func close() {
        guard isConnected else { return }
        IOServiceClose(conn)
        conn = 0
        isConnected = false
    }

    // Low-level SMC call
    private func call(_ index: UInt8, input: inout SMCKeyData_t, output: inout SMCKeyData_t) -> kern_return_t {
        var inputSize = MemoryLayout<SMCKeyData_t>.size
        var outputSize = MemoryLayout<SMCKeyData_t>.size
        return IOConnectCallStructMethod(conn, UInt32(index), &input, inputSize, &output, &outputSize)
    }

    // Read a raw SMC value
    private func read(_ key: String) -> SMCVal_t? {
        var val = SMCVal_t(key)

        // First, get key info
        var input = SMCKeyData_t()
        var output = SMCKeyData_t()

        input.key = FourCharCode(fromString: key)
        input.data8 = SMCKeys.readKeyInfo.rawValue

        var result = call(SMCKeys.kernelIndex.rawValue, input: &input, output: &output)
        if result != kIOReturnSuccess {
            return nil
        }

        val.dataSize = output.keyInfo.dataSize
        val.dataType = FourCharCode(output.keyInfo.dataType).toString()

        // Read the actual value
        input = SMCKeyData_t()
        input.key = FourCharCode(fromString: key)
        input.data8 = SMCKeys.readBytes.rawValue

        result = call(SMCKeys.kernelIndex.rawValue, input: &input, output: &output)
        if result != kIOReturnSuccess {
            return nil
        }

        withUnsafeMutablePointer(to: &output.bytes) { ptr in
            let raw = ptr.withMemoryRebound(to: UInt8.self, capacity: 32) { $0 }
            val.bytes = Array(UnsafeBufferPointer(start: raw, count: 32))
        }

        return val
    }

    // Get a numeric value from SMC
    public func getValue(_ key: String) -> Double? {
        guard let val = read(key) else { return nil }

        if val.dataSize == 0 {
            return nil
        }

        // Check for all-zero values (usually means key not supported)
        if val.bytes.first(where: { $0 != 0 }) == nil {
            return nil
        }

        switch val.dataType {
        case SMCDataType.UI8.rawValue:
            return Double(val.bytes[0])
        case SMCDataType.UI16.rawValue:
            return Double(UInt16(bytes: (val.bytes[0], val.bytes[1])))
        case SMCDataType.UI32.rawValue:
            return Double(UInt32(bytes: (val.bytes[0], val.bytes[1], val.bytes[2], val.bytes[3])))
        case SMCDataType.SP78.rawValue:
            // SP78: signed 8.8 fixed-point, divide by 256
            let intValue = Double(Int(val.bytes[0]) * 256 + Int(val.bytes[1]))
            return intValue / 256.0
        case SMCDataType.FPE2.rawValue:
            return Double(Int(fromFPE2: (val.bytes[0], val.bytes[1])))
        default:
            print("SMC: unsupported type \(val.dataType) for key \(key)")
            return nil
        }
    }

    // Get all available SMC keys
    public func getAllKeys() -> [String] {
        var list: [String] = []

        guard let keysNum = getValue("#KEY") else {
            print("SMC: could not read #KEY")
            return list
        }

        for i in 0...Int(keysNum) {
            var input = SMCKeyData_t()
            var output = SMCKeyData_t()

            input.data8 = SMCKeys.readIndex.rawValue
            input.data32 = UInt32(i)

            let result = call(SMCKeys.kernelIndex.rawValue, input: &input, output: &output)
            if result != kIOReturnSuccess {
                continue
            }

            list.append(output.key.toString())
        }

        return list
    }

    // MARK: - Temperature Keys (Apple Silicon Mac mini)

    // Common temperature sensor keys on Apple Silicon:
    // TC0P/TC0D/TC0H = CPU Die proximity
    // TC0P = CPU Proximity
    // TG0P/TG0D/TG0H = GPU Die
    // Ts0P/Ts0H = SSD temperature
    // Tu0P/Tu0H = GPU proximity

    public func readTemperature(_ key: String) -> Double? {
        return getValue(key)
    }

    // Read all known temperature keys and return the first non-nil result
    public func getCpuTemperature() -> Double? {
        let keys = ["TC0P", "TC0D", "TC0H", "TC0C", "TCMP", "Tp01", "Tp02", "Tp03"]
        for key in keys {
            if let temp = getValue(key), temp > 0, temp < 150 {
                print("SMC: \(key) = \(temp)")
                return temp
            }
        }
        return nil
    }

    public func getGpuTemperature() -> Double? {
        let keys = ["TG0P", "TG0D", "TG0H", "TG0D", "TG0T", "TGXP", "Tg07", "Tg08", "Tg09"]
        for key in keys {
            if let temp = getValue(key), temp > 0, temp < 150 {
                print("SMC: \(key) = \(temp)")
                return temp
            }
        }
        return nil
    }
}
