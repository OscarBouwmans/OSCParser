
import Testing
@testable import OSCParser

@Test func oscArgumentFloat32fromValue() async throws {
    let argument = OSCFloat32Argument(value: 3.14159)
    #expect(argument.value == 3.14159)
    #expect(argument.buffer == [64, 73, 15, 208])
    
    let negative = OSCFloat32Argument(value: -3.14159)
    #expect(negative.value == -3.14159)
    #expect(negative.buffer == [192, 73, 15, 208])
}

@Test func oscArgumentFloat32fromBuffer() async throws {
    let buffer: [UInt8] = [64, 73, 15, 208]
    let argument = try OSCFloat32Argument(from: buffer)
    #expect(argument.value == 3.14159)
    #expect(argument.buffer == buffer)
    
    let negativeBuffer: [UInt8] = [192, 73, 15, 208]
    let negative = try OSCFloat32Argument(from: negativeBuffer)
    #expect(negative.value == -3.14159)
    #expect(negative.buffer == negativeBuffer)
    
    let invalidBuffers: [[UInt8]] = [
        [],
        [0, 0, 0],
        [0, 0, 0, 0, 0],
    ]
    
    for invalidBuffer in invalidBuffers {
        #expect(throws: OSCPacketError.invalidArgumentBuffer, performing: {
            try OSCFloat32Argument(from: invalidBuffer)
        })
    }
}
