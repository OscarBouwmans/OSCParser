
public struct OSCStringArgument: OSCArgumentWithData {
    public let typeTag = OSCTypeTag.string
    public let value: String
    
    public var buffer: [UInt8] {
        value.toOSCString()
    }
    
    public init(value: String) {
        self.value = value
    }
    
    public init(from buffer: [UInt8]) throws {
        guard let firstNullIndex = buffer.firstIndex(of: 0) else {
            throw OSCPacketError.invalidArgumentBuffer
        }
        let stringValue = String(decoding: buffer[0..<firstNullIndex], as: UTF8.self)
        self.value = stringValue
    }
}
