
public func parseOSCPacket(_ buffer: [UInt8]) throws -> any OSCPacket {
    switch buffer.first {
    case "/".utf8.first!:
        return try OSCMessage(from: buffer)
    case "#".utf8.first!:
        return try OSCBundle(from: buffer)
    default:
        throw OSCPacketError.invalidPacket
    }
}
