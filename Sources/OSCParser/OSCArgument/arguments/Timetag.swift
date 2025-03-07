
public struct OSCTimetagArgument: OSCArgumentWithData {
    public let typeTag = OSCTypeTag.timetag
    public let value: OSCTimetag
    
    public var buffer: [UInt8] {
        return value.buffer
    }
    
    public init(value: OSCTimetag) {
        self.value = value
    }
    
    public init(from buffer: [UInt8]) throws {
        do {
            self.value = try OSCTimetag(from: buffer)
        }
        catch {
            throw OSCPacketError.invalidArgumentBuffer
        }
    }
}
