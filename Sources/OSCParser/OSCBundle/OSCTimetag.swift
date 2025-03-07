
import Foundation

public struct OSCTimetag: Equatable, Sendable {
    public let rawValue: UInt64
    
    var secondsSince1900: UInt32 {
        UInt32(rawValue >> 32)
    }
    
    var fraction: UInt32 {
        UInt32(rawValue & 0xFFFFFFFF)
    }
    
    var isImmediately: Bool {
        rawValue == 1
    }
    
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    public init(_ reserved: ReservedValues) {
        switch reserved {
        case .immediately:
            self.init(rawValue: 1)
        }
    }
    
    init(from buffer: [UInt8]) throws {
        guard let rawValue = bytesToUInt64(buffer) else {
            throw TimetagError.invalidTimetagBuffer
        }
        self.init(rawValue: rawValue)
    }
    
    public var buffer: [UInt8] {
        withUnsafeBytes(of: rawValue.bigEndian) { Array($0) }
    }
    
    public enum TimetagError: Error {
        case invalidTimetagBuffer
    }
    
    public enum ReservedValues {
        case immediately
    }
}

private func bytesToUInt64(_ bytes: [UInt8]) -> UInt64? {
    guard bytes.count == 8 else { return nil }
    return bytes.prefix(8).enumerated().reduce(0) { result, byte in
        result + (UInt64(byte.element) << (56 - 8 * byte.offset))
    }
}
