
import Testing
@testable import OSCParser

@Test func oscArgumentInt32fromValue() async throws {
    let argument = OSCInt32Argument(value: 42)
    #expect(argument.buffer == [0, 0, 0, 42])
    
    let negative = OSCInt32Argument(value: -42)
    #expect(negative.buffer == [255, 255, 255, 214])
}

@Test func oscArgumentInt32fromBuffer() async throws {
    let buffer: [UInt8] = [0, 0, 0, 42]
    let argument = try OSCInt32Argument(from: buffer)
    #expect(argument.buffer == buffer)
    
    let negativeBuffer: [UInt8] = [255, 255, 255, 214]
    let negative = try OSCInt32Argument(from: negativeBuffer)
    #expect(negative.buffer == negativeBuffer)
    
    let invalidBuffers: [[UInt8]] = [
        [],
        [0, 0, 0],
        [0, 0, 0, 0, 0],
    ]
    
    for invalidBuffer in invalidBuffers {
        #expect(throws: OSCPacketError.invalidArgumentBuffer, performing: {
            try OSCInt32Argument(from: invalidBuffer)
        })
    }
}
