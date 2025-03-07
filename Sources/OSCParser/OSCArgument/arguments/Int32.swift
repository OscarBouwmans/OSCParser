
public struct OSCInt32Argument: OSCArgumentWithData {
    public let typeTag = OSCTypeTag.int32
    public let value: Int32
    
    public var buffer: [UInt8] {
        withUnsafeBytes(of: value.bigEndian) { Array($0) }
    }
    
    public init(value: Int32) {
        self.value = value
    }
    
    public init(from buffer: [UInt8]) throws {
        guard buffer.count == 4 else {
            throw OSCPacketError.invalidArgumentBuffer
        }
        self.value = buffer.withUnsafeBytes { $0.load(as: Int32.self) }.bigEndian
    }
}
