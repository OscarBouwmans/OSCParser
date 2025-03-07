
typealias SlipStreamSingleByteParser = (_: UInt8) -> SlipStreamParserResult

struct SlipStreamParserResult {
    let nextParser: SlipStreamSingleByteParser
    let packet: OSCPacket?
    
    init(nextParser: @escaping SlipStreamSingleByteParser, result packet: OSCPacket? = nil) {
        self.nextParser = nextParser
        self.packet = packet
    }
}

public class OSCSlipStreamParser {
    private var currentParser: SlipStreamSingleByteParser
    
    private var parsedPacketQueue: [any OSCPacket] = [];
    
    public init() {
        self.currentParser = OSCSlipStreamParser.defaultParser()
    }
    
    public func push(_ bytes: [UInt8]) {
        for byte in bytes {
            let result = self.currentParser(byte)
            if let packet = result.packet {
                parsedPacketQueue.append(packet)
            }
            self.currentParser = result.nextParser
        }
    }
    
    public var pendingPacketCount: Int {
        return parsedPacketQueue.count
    }
    
    public func next() -> (any OSCPacket)? {
        guard parsedPacketQueue.count > 0 else { return nil }
        return parsedPacketQueue.removeFirst()
    }
    
    public func next() -> [any OSCPacket] {
        let packets = parsedPacketQueue
        parsedPacketQueue.removeAll()
        return packets
    }
    
    private static let END: UInt8 = 0xC0
    private static let ESC: UInt8 = 0xDB
    private static let ESC_END: UInt8 = 0xDC
    private static let ESC_ESC: UInt8 = 0xDD
    
    private static func defaultParser(_ buffer: [UInt8] = []) -> SlipStreamSingleByteParser {
        return { byte in
            switch byte {
            case END: // END
                guard buffer.count > 0 else {
                    return SlipStreamParserResult(nextParser: defaultParser())
                }
                
                do {
                    let packet = try parseOSCPacket(buffer)
                    return SlipStreamParserResult(nextParser: defaultParser(), result: packet)
                }
                catch let error {
                    return SlipStreamParserResult(nextParser: defaultParser())
                }
            case ESC: // ESC
                return SlipStreamParserResult(nextParser: escapingParser(buffer))
            default:
                return SlipStreamParserResult(nextParser: defaultParser(buffer + [byte]))
            }
        }
    }
    
    private static func escapingParser(_ buffer: [UInt8] = []) -> SlipStreamSingleByteParser {
        return { byte in
            switch byte {
            case ESC_END: // ESC_END
                return SlipStreamParserResult(nextParser: defaultParser(buffer + [END]))
            case ESC_ESC: // ESC_ESC
                return SlipStreamParserResult(nextParser: defaultParser(buffer + [ESC]))
            default:
                // We must never end up here. Faulty stream => reset.
                return SlipStreamParserResult(nextParser: defaultParser())
            }
        }
    }
}
