
import Testing
@testable import OSCParser

@Test func oscArgumentTimetagFromValue() async throws {
    let timetag = OSCTimetag(.immediately)
    let timetagArgument = OSCTimetagArgument(value: timetag)
    #expect(timetagArgument.typeTag == .timetag)
    #expect(timetagArgument.value == timetag)
    #expect(timetagArgument.buffer == timetag.buffer)
}

@Test func oscArgumentTimetagFromBuffer() async throws {
    let timetagBuffer: [UInt8] = [0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF]
    let timetag = try OSCTimetag(from: timetagBuffer)
    let timetagArgument = try OSCTimetagArgument(from: timetagBuffer)
    #expect(timetagArgument.typeTag == .timetag)
    #expect(timetagArgument.value == timetag)
    #expect(timetagArgument.buffer == timetagBuffer)
}

@Test func oscArgumentTimetagFromInvalidBuffer() async throws {
    let invalidBuffers: [[UInt8]] = [
        [],
        [0x01, 0x02],
        [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00],
    ]
    for invalidBuffer in invalidBuffers {
        #expect(throws: OSCPacketError.invalidArgumentBuffer, performing: {
            try OSCTimetagArgument(from: invalidBuffer)
        })
    }
}
