
import Testing
@testable import OSCParser

@Test func oscSlipStreamParserSlipProtocol() async throws {
    let messageWithEscapedCharacters = OSCMessage(address: ["hello", "À", "world"], arguments: [
        OSCStringArgument(value: "WÛT"),
        OSCStringArgument(value: "is happÜning"),
        OSCInt32Argument(value: 221),
        OSCStringArgument(value: "here?"),
    ])
    let nonsenseMessage = OSCMessage(address: ["nonsense"], arguments: [
        OSCFloat32Argument(value: -6.870711), // c0dbdcdd
        OSCStringArgument(value: "padding"),
        OSCFloat32Argument(value: -1.7158182), // bfdb9fee
    ])
    let encodedMessages = [UInt8](
        [UInt8]([0x24, 0x54, 0xE8]) +
        encodeSlip(buffer: messageWithEscapedCharacters.buffer) +
        encodeSlip(buffer: nonsenseMessage.buffer) +
        [UInt8]([0x94, 0x0F, 0x4A])
    )
    
    let parser = OSCSlipStreamParser()
    parser.push(encodedMessages)
    
    #expect(parser.pendingPacketCount == 2)
    let packet1: (any OSCPacket)? = parser.next()
    let packet2: (any OSCPacket)? = parser.next()
    #expect(packet1 is OSCMessage)
    #expect(packet2 is OSCMessage)
    #expect(parser.next() == nil)
    
    #expect(packet1?.buffer == messageWithEscapedCharacters.buffer)
    #expect(packet2?.buffer == nonsenseMessage.buffer)
}

@Test func oscSlipStreamParserNextMayBeArray() async throws {
    let messageA = OSCMessage(address: ["a"])
    let messageB = OSCMessage(address: ["b"])
    let messageC = OSCMessage(address: ["c"])
    
    let encoded = [UInt8](
        encodeSlip(buffer: messageA.buffer) +
        encodeSlip(buffer: messageB.buffer) +
        encodeSlip(buffer: messageC.buffer)
    )
    
    let parser = OSCSlipStreamParser()
    parser.push(encoded)
    
    #expect(parser.pendingPacketCount == 3)
    let allPackets: [OSCPacket] = parser.next()
    
    #expect(allPackets.count == 3)
    #expect(allPackets[0].buffer == messageA.buffer)
    #expect(allPackets[1].buffer == messageB.buffer)
    #expect(allPackets[2].buffer == messageC.buffer)
}

@Test func oscSlipStreamParserInvalidStream() async throws {
    var invalidStream = [UInt8](0..<255)
    invalidStream[10] = 0xDB // ESC
    invalidStream[40] = 0xDB // ESC
    let validMessage = encodeSlip(buffer: OSCMessage(address: ["hello"]).buffer)
    
    let parser = OSCSlipStreamParser()
    parser.push(validMessage + invalidStream + validMessage)
    
    #expect(parser.pendingPacketCount == 2)
    let packet1: (any OSCPacket)? = parser.next()
    let packet2: (any OSCPacket)? = parser.next()
    #expect(packet1 is OSCMessage)
    #expect(packet2 is OSCMessage)
    #expect(packet1?.buffer == OSCMessage(address: ["hello"]).buffer)
    #expect(packet2?.buffer == OSCMessage(address: ["hello"]).buffer)
}
