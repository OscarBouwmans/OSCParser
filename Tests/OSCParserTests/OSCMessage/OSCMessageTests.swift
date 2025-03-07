
import Testing
@testable import OSCParser

@Test func oscMessageWithoutArguments() async throws {
    let message = OSCMessage(address: ["hello", "world"])
    #expect(message.addressParts.count == 2)
    #expect(message.addressParts[0] == "hello")
    #expect(message.addressParts[1] == "world")
    #expect(message.buffer == [47, 104, 101, 108, 108, 111, 47, 119, 111, 114, 108, 100, 0, 0, 0, 0, 44, 0, 0, 0])
    #expect(message.arguments.isEmpty)
}

@Test func oscMessageWithArguments() async throws {
    let message = OSCMessage(address: ["hello", "world"], arguments: [
        OSCStringArgument(value: "hello"),
        OSCTrueArgument(),
        OSCInt32Argument(value: 42),
        OSCNullArgument(),
    ])
    #expect(message.addressParts.count == 2)
    #expect(message.addressParts[0] == "hello")
    #expect(message.addressParts[1] == "world")
    #expect(message.buffer == [
        47, 104, 101, 108, 108, 111, 47, 119, 111, 114, 108, 100, 0, 0, 0, 0,
        44, 115, 84, 105, 78, 0, 0, 0,
        104, 101, 108, 108, 111, 0, 0, 0,
        0, 0, 0, 42
    ])
    #expect(message.arguments.count == 4)
    #expect(message.arguments[0] as? OSCStringArgument == OSCStringArgument(value: "hello"))
    #expect(message.arguments[1] as? OSCTrueArgument == OSCTrueArgument())
    #expect(message.arguments[2] as? OSCInt32Argument == OSCInt32Argument(value: 42))
    #expect(message.arguments[3] as? OSCNullArgument == OSCNullArgument())
}

@Test func oscMessageFromInvalidBuffers() async throws {
    // non-multiple of 4
    #expect(throws: OSCPacketError.invalidPacket, performing: {
        try OSCMessage(from: [0, 0, 0])
    })
    
    // non-existent type tag
    #expect(throws: OSCPacketError.unrecognizedTypeTag, performing: {
        try OSCMessage(from: [47, 104, 101, 108, 108, 111, 0, 0, 44, 120, 0, 0])
    })
}
