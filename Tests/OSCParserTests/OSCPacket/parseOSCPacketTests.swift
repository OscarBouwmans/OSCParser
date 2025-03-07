
import Testing
@testable import OSCParser

@Test func oscPacketInvalidStart() async throws {
    // does not start with # or /
    #expect(throws: OSCPacketError.invalidPacket, performing: {
        try parseOSCPacket("something".toOSCString())
    })
}
