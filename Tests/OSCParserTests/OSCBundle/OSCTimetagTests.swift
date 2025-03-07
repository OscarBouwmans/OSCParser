
import Testing
@testable import OSCParser

@Test func oscTimetagFromRawValue() async throws {
    let rawValue = UInt64(0x0123456789ABCDEF)
    let timetag = OSCTimetag(rawValue: rawValue)
    #expect(timetag.rawValue == rawValue)
    #expect(timetag.secondsSince1900 == 0x01234567)
    #expect(timetag.fraction == 0x89ABCDEF)
    #expect(timetag.isImmediately == false)
    #expect(timetag.buffer == [0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF])
}

@Test func oscTimetagImmediate() async throws {
    let notImmediately = [
        OSCTimetag(rawValue: 0),
        OSCTimetag(rawValue: 5748),
        OSCTimetag(rawValue: 0xFFFFFFFFFFFFFFFF),
    ]
    for timetag in notImmediately {
        #expect(timetag.isImmediately == false)
    }
    
    let immediately = OSCTimetag(rawValue: 1)
    #expect(immediately.rawValue == 1)
    #expect(immediately.isImmediately)
    
    let alsoImmediately = OSCTimetag(.immediately)
    #expect(alsoImmediately.rawValue == 1)
    #expect(alsoImmediately.isImmediately)
}

@Test func oscTimetagFromBuffer() async throws {
    let rawValue = UInt64(0x0123456789ABCDEF)
    let buffer = [UInt8]([0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF])
    let timetag = try OSCTimetag(from: buffer)
    #expect(timetag.rawValue == rawValue)
    
    let invalidBuffers: [[UInt8]] = [
        [],
        [0x01, 0x02],
        [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
    ]
    for invalidBuffer in invalidBuffers {
        #expect(throws: OSCTimetag.TimetagError.invalidTimetagBuffer, performing: {
            try OSCTimetag(from: invalidBuffer)
        })
    }
}
