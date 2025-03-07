
public struct OSCBlobArgument: OSCArgumentWithData {
    public let typeTag = OSCTypeTag.blob
    public let value: [UInt8]
    
    public var buffer: [UInt8] {
        let size: Int32 = Int32(value.count)
        let sizeBytes = withUnsafeBytes(of: size) { Array($0) }
        let paddedValue = value + Array<UInt8>(repeating: UInt8(0), count: (4 - (value.count % 4)) % 4)
        return sizeBytes + paddedValue
    }
    
    public init(value: [UInt8]) {
        self.value = value
    }
    
    public init(from buffer: [UInt8]) throws {
        let size = buffer[0..<4].withUnsafeBytes { $0.load(as: Int32.self) }
        guard size > 0 else {
            throw OSCPacketError.invalidPacket
        }
        self.value = Array(buffer[4..<4+Int(size)])
    }
}
