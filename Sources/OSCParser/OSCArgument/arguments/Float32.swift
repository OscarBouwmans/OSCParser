
public struct OSCFloat32Argument: OSCArgumentWithData {
    public let typeTag = OSCTypeTag.float32
    public let value: Float32
    
    public var buffer: [UInt8] {
        let networkOrder = value.bitPattern.bigEndian
        return withUnsafeBytes(of: networkOrder) { Array($0) }
    }
    
    public init(value: Float32) {
        self.value = value
    }
    
    public init(from buffer: [UInt8]) throws {
        guard buffer.count == 4 else {
            throw OSCPacketError.invalidArgumentBuffer
        }
        let rawUInt32 = buffer.withUnsafeBytes { $0.load(as: UInt32.self) }
        self.value = Float32(bitPattern: UInt32(bigEndian: rawUInt32))
    }
}
