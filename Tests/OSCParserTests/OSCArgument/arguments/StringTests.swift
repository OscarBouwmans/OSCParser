
import Testing
@testable import OSCParser

@Test func oscArgumentStringFromValue() async throws {
    let testString = "hello"
    let argument = OSCStringArgument(value: testString)
    // "hello" -> [104, 101, 108, 108, 111] + null terminator + pad to 8 bytes total.
    let expected: [UInt8] = [104, 101, 108, 108, 111, 0, 0, 0]
    #expect(argument.buffer == expected)
    
    let eightCharacterString = "abcdefgh"
    let eightCharacterArgument = OSCStringArgument(value: eightCharacterString)
    // "abcdefgh" -> [97, 98, 99, 100, 101, 102, 103, 104] + null terminator + pad to 12 bytes total.
    let eightCharacterExpected: [UInt8] = [97, 98, 99, 100, 101, 102, 103, 104, 0, 0, 0, 0]
    #expect(eightCharacterArgument.buffer == eightCharacterExpected)
}

@Test func oscArgumentStringFromBuffer() async throws {
    // Buffer representing "world": [119,111,114,108,100] + null + pad.
    let buffer: [UInt8] = [119, 111, 114, 108, 100, 0, 0, 0]
    let argument = try OSCStringArgument(from: buffer)
    #expect(argument.value == "world")
}

@Test func oscArgumentStringInvalidBufferThrows() async throws {
    // Buffer with invalid UTF8 (0xFF is invalid).
    let buffer: [UInt8] = [0xFF, 0xFF, 0, 0]
    #expect(throws: OSCPacketError.invalidPacket, performing: {
        try OSCStringArgument(from: buffer)
    })
    
    // Buffer with no null terminator.
    let buffer2: [UInt8] = [104, 101, 108, 108, 111]
    #expect(throws: OSCPacketError.invalidArgumentBuffer, performing: {
        try OSCStringArgument(from: buffer2)
    })
}
