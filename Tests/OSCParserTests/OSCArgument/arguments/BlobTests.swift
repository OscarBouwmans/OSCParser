
import Testing
@testable import OSCParser

@Test func oscArgumentBlobFromValue() async throws {
    let data: [UInt8] = [1, 2, 3, 4, 5]
    let argument = OSCBlobArgument(value: data)
    
    // Size (5) as bytes in host order.
    let size: Int32 = 5
    let sizeBytes = withUnsafeBytes(of: size) { Array($0) }
    // Pad with 3 zeros: (4 - (5 % 4)) % 4 = 3.
    let paddedData = data + [0, 0, 0]
    let expected = sizeBytes + paddedData
    #expect(argument.buffer == expected)
}

@Test func oscArgumentBlobFromBuffer() async throws {
    // Blob with 4 bytes of data (no extra padding needed).
    let data: [UInt8] = [10, 20, 30, 40]
    let size: Int32 = 4
    let sizeBytes = withUnsafeBytes(of: size) { Array($0) }
    let buffer: [UInt8] = sizeBytes + data
    let argument = try OSCBlobArgument(from: buffer)
    #expect(argument.value == data)
}

@Test func oscArgumentBlobFromBufferWithPadding() async throws {
    // Blob with 3 bytes of data (will be padded with one zero).
    let data: [UInt8] = [7, 8, 9]
    let size: Int32 = 3
    let sizeBytes = withUnsafeBytes(of: size) { Array($0) }
    let paddedData = data + [0]  // (4 - (3 % 4)) % 4 = 1
    let buffer: [UInt8] = sizeBytes + paddedData
    let argument = try OSCBlobArgument(from: buffer)
    #expect(argument.value == data)
}

@Test func oscArgumentBlobInvalidBufferThrows() async throws {
    // A size of 0 should trigger an error.
    let size: Int32 = 0
    let sizeBytes = withUnsafeBytes(of: size) { Array($0) }
    let buffer: [UInt8] = sizeBytes  // No blob data follows.
    #expect(throws: OSCPacketError.invalidPacket, performing: {
        try OSCBlobArgument(from: buffer)
    })
}
