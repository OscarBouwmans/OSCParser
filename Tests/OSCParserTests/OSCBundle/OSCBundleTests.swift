
import Testing
@testable import OSCParser

@Test func oscBundleEmpty() async throws {
    let bundle = OSCBundle(at: OSCTimetag(.immediately), with: [])
    #expect(bundle.timetag.isImmediately == true)
    #expect(bundle.elements.isEmpty)
    #expect(bundle.buffer.count == 16)
}

@Test func oscBundleWithMessages() async throws {
    let messages = [
        OSCMessage(address: ["foo"]),
        OSCMessage(address: ["bar"], arguments: [OSCStringArgument(value: "hello")]),
    ]
    let bundle = OSCBundle(at: OSCTimetag(.immediately), with: messages)
    #expect(bundle.timetag.isImmediately == true)
    #expect(bundle.elements.count == 2)
    #expect(bundle.elements[0] is OSCMessage)
    #expect(bundle.elements[1] is OSCMessage)
    #expect(bundle.buffer.count == 16 + 4 + messages[0].buffer.count + 4 + messages[1].buffer.count)
    
    let element0Offset = 16 + 4
    let element1Offset = element0Offset + messages[0].buffer.count + 4
    
    #expect([UInt8](bundle.buffer[element0Offset..<element0Offset + messages[0].buffer.count]) == messages[0].buffer)
    #expect([UInt8](bundle.buffer[element1Offset..<element1Offset + messages[1].buffer.count]) == messages[1].buffer)
}

@Test func oscBundleWithMessagesAndNestedBundles() async throws {
    let elements: [OSCPacket] = [
        OSCMessage(address: ["foo"]),
        OSCBundle(at: OSCTimetag(.immediately), with: [
            OSCMessage(address: ["hello"], arguments: [OSCInt32Argument(value: 42)]),
            OSCMessage(address: ["world"]),
        ]),
        OSCMessage(address: ["bar"], arguments: [OSCStringArgument(value: "hello")]),
    ]
    let bundle = OSCBundle(at: OSCTimetag(.immediately), with: elements)
    #expect(bundle.elements.count == 3)
    #expect(bundle.elements[0] is OSCMessage)
    #expect(bundle.elements[1] is OSCBundle)
    #expect(bundle.elements[2] is OSCMessage)
    #expect(bundle.buffer.count == 16 + 4 + elements[0].buffer.count + 4 + elements[1].buffer.count + 4 + elements[2].buffer.count)
    
    let element0Offset = 16 + 4
    let element1Offset = element0Offset + (elements[0] as! OSCMessage).buffer.count + 4
    let element2Offset = element1Offset + (elements[1] as! OSCBundle).buffer.count + 4
    
    let element0 = bundle.elements[0] as! OSCMessage
    let element1 = bundle.elements[1] as! OSCBundle
    let element2 = bundle.elements[2] as! OSCMessage
    
    #expect([UInt8](bundle.buffer[element0Offset..<element0Offset + element0.buffer.count]) == element0.buffer)
    #expect([UInt8](bundle.buffer[element1Offset..<element1Offset + element1.buffer.count]) == element1.buffer)
    #expect([UInt8](bundle.buffer[element2Offset..<element2Offset + element2.buffer.count]) == element2.buffer)
    
    #expect((bundle.elements[1] as? OSCBundle)?.elements.count == 2)
}

@Test func oscBundleFromBuffer() async throws {
    let complicatedBundle = OSCBundle(at: OSCTimetag(rawValue: 0x0123456789ABCDEF), with: [
        OSCMessage(address: ["foo", "bar", "baz"], arguments: [OSCStringArgument(value: "hello"), OSCInt32Argument(value: 42)]),
        OSCMessage(address: ["bar", "qux", "baz"], arguments: [OSCInt32Argument(value: 1337)]),
        OSCBundle(at: OSCTimetag(.immediately), with: [
            OSCMessage(address: ["baz"], arguments: [
                OSCInt32Argument(value: 6),
                OSCFloat32Argument(value: 3.14),
                OSCStringArgument(value: "hello"),
                OSCInt32Argument(value: 42),
                OSCFloat32Argument(value: 5345973485.594734),
            ]),
            OSCMessage(address: ["qux"]),
            OSCBundle(at: OSCTimetag(.immediately), with: [
                OSCMessage(address: ["hello", "world"]),
            ]),
            OSCBundle(at: OSCTimetag(.immediately), with: [])
        ]),
        OSCMessage(address: ["baz", "hello", "world"], arguments: [OSCBlobArgument(value: [0x01, 0x02, 0x03, 0x04])]),
    ])
    
    let reconstructedBundle = try OSCBundle(from: complicatedBundle.buffer)
    
    #expect(reconstructedBundle.timetag == complicatedBundle.timetag)
    #expect(reconstructedBundle.elements.count == complicatedBundle.elements.count)
    #expect(reconstructedBundle.buffer == complicatedBundle.buffer)
}

@Test func oscBundleFromInvalidBuffer() async throws {
    let invalidStart = "#bundLEnotabundle".toOSCString()
    #expect(throws: OSCPacketError.invalidBundleBuffer, performing: {
        try OSCBundle(from: invalidStart)
    })
    
    let shortBuffer = [UInt8]([0x34, 0x12, 0x34, 0x56])
    #expect(throws: OSCPacketError.invalidPacket, performing: {
        try OSCBundle(from: shortBuffer)
    })
}
