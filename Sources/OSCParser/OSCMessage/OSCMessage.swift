public struct OSCMessage: OSCPacket {
    public let addressParts: [String]
    public let arguments: [any OSCArgument]
    
    public var buffer: [UInt8] {
        let address = ("/" + addressParts.joined(separator: "/")).toOSCString()
        let typeTags = ("," + arguments.map { "\($0.typeTag.rawValue)" }.joined()).toOSCString()
        let argumentValues = arguments.flatMap { argument in
            if let withValue = argument as? (any OSCArgumentWithData) {
                return withValue.buffer
            }
            return []
        }
        
        return address + typeTags + argumentValues
    }
    
    public init(address parts: [String], arguments: [any OSCArgument] = []) {
        self.addressParts = parts
        self.arguments = arguments
    }
    
    init(from buffer: [UInt8]) throws {
        guard buffer.count % 4 == 0 else {
            throw OSCPacketError.invalidPacket
        }
        let firstNullIndex = buffer.firstIndex(of: 0)!
        let address = String(decoding: buffer[..<firstNullIndex], as: UTF8.self)
        let typeTagsStartIndex = firstNullIndex + (4 - (firstNullIndex % 4))
        let typeTagsEndIndex = buffer[typeTagsStartIndex...].firstIndex(of: 0)!
        let typeTags = String(decoding: buffer[typeTagsStartIndex..<typeTagsEndIndex], as: UTF8.self)
        
        var nextArgumentIndex = typeTagsEndIndex + (4 - (typeTagsEndIndex % 4))
        var arguments: [any OSCArgument] = []
        for typeTagString in typeTags {
            if typeTagString == "," { continue }
            guard let typeTag = OSCTypeTag(rawValue: typeTagString) else {
                throw OSCPacketError.unrecognizedTypeTag
            }
            let offsetBuffer = [UInt8](buffer[nextArgumentIndex...])
            let (argument, shift) = try parseOSCArgument(typeTag, using: offsetBuffer)
            arguments.append(argument)
            nextArgumentIndex += shift
        }
        
        self.addressParts = address.split(separator: "/").map(String.init)
        self.arguments = arguments
    }
}

public extension OSCMessage {
    init(_ address: String, _ arguments: any OSCArgument...) {
        self.init(address: address.split(separator: "/").map(String.init), arguments: arguments)
    }
}

public extension String {
    func toOSCString() -> [UInt8] {
        let utf8Bytes = Array(self.utf8)
        let nullTerminator: [UInt8] = [0]
        let paddingLength = (4 - ((utf8Bytes.count + 1) % 4)) % 4
        let padding = Array(repeating: UInt8(0), count: paddingLength)
        
        return utf8Bytes + nullTerminator + padding
    }
}
