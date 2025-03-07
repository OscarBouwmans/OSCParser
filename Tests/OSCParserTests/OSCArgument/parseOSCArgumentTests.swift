
import Testing
@testable import OSCParser

@Test func parseOscArgumentsWithData() throws {
    let arguments: [any OSCArgumentWithData] = [
        OSCInt32Argument(value: 42),
        OSCFloat32Argument(value: 3.14),
        OSCStringArgument(value: "Hello"),
        OSCBlobArgument(value: [1, 2, 3, 4]),
        OSCTimetagArgument(value: OSCTimetag(.immediately)),
    ]
    
    for argument in arguments {
        let (parsed, bytesUsed) = try parseOSCArgument(argument.typeTag, using: argument.buffer)
        
        #expect(parsed is (any OSCArgumentWithData))
        #expect(parsed.typeTag == argument.typeTag)
        #expect((parsed as? (any OSCArgumentWithData))?.buffer == argument.buffer)
        #expect(bytesUsed == argument.buffer.count)
    }
}

@Test func parseOscArgumentsWithoutData() throws {
    let arguments: [any OSCArgument] = [
        OSCTrueArgument(),
        OSCFalseArgument(),
        OSCNullArgument(),
        OSCImpulseArgument(),
    ]
    
    for argument in arguments {
        let (parsed, bytesUsed) = try parseOSCArgument(argument.typeTag, using: [])
        
        #expect(parsed is (any OSCArgumentWithData) == false)
        #expect(parsed.typeTag == argument.typeTag)
        #expect(bytesUsed == 0)
    }
}
