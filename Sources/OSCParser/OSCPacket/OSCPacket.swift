
public protocol OSCPacket: Sendable {
    var buffer: [UInt8] { get }
}

public enum OSCPacketError: Error {
    case invalidPacket
    case invalidBundleBuffer
    case invalidArgumentBuffer
    case unrecognizedTypeTag
}
