
import Testing
@testable import OSCParser

@Test func encodeEmptyBuffer() async throws {
    let buffer: [UInt8] = []
    let encoded = encodeSlip(buffer: buffer)
    #expect(encoded == [0xC0, 0xC0])
}

@Test func encodeNoSpecialBytes() async throws {
    let buffer: [UInt8] = [1, 2, 3, 4, 5]
    let encoded = encodeSlip(buffer: buffer)
    #expect(encoded == [0xC0, 1, 2, 3, 4, 5, 0xC0])
}

@Test func encodeSingleEndMarker() async throws {
    let buffer: [UInt8] = [0xC0]
    let encoded = encodeSlip(buffer: buffer)
    #expect(encoded == [0xC0, 0xDB, 0xDC, 0xC0])
}

@Test func encodeSingleEscapeMarker() async throws {
    let buffer: [UInt8] = [0xDB]
    let encoded = encodeSlip(buffer: buffer)
    #expect(encoded == [0xC0, 0xDB, 0xDD, 0xC0])
}

@Test func encodeMultipleSpecialBytes() async throws {
    let buffer: [UInt8] = [0, 0xC0, 0xDB, 0xC0, 0xDB]
    let encoded = encodeSlip(buffer: buffer)
    let expected: [UInt8] = [
        0xC0,         // Start marker
        0,
        0xDB, 0xDC,   // Escaped 0xC0
        0xDB, 0xDD,   // Escaped 0xDB
        0xDB, 0xDC,   // Escaped 0xC0
        0xDB, 0xDD,   // Escaped 0xDB
        0xC0          // End marker
    ]
    #expect(encoded == expected)
}

@Test func encodeLargeBuffer() async throws {
    // Create a buffer of 120 bytes, filled with 42 (arbitrary non-special value)
    var buffer = [UInt8](repeating: 0, count: 1000)
    for i in 0..<buffer.count {
        buffer[i] = UInt8(i % 128)
        if i % 10 == 0 {
            buffer[i] = 0xC0
        }
        if i % 7 == 0 {
            buffer[i] = 0xDB
        }
    }
    let encoded = encodeSlip(buffer: buffer)

    var expected: [UInt8] = [0xC0]
    for byte in buffer {
        if byte == 0xC0 {
            expected.append(contentsOf: [0xDB, 0xDC])
        } else if byte == 0xDB {
            expected.append(contentsOf: [0xDB, 0xDD])
        } else {
            expected.append(byte)
        }
    }
    expected.append(0xC0)

    #expect(encoded == expected)
}
