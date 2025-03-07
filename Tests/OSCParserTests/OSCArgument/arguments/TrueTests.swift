
import Testing
@testable import OSCParser

@Test func oscArgumentTrue() async throws {
    let trueArgument = OSCTrueArgument()
    #expect(trueArgument.typeTag == .true)
}
