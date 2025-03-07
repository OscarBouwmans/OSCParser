
import Testing
@testable import OSCParser

@Test func oscArgumentNull() async throws {
    let nullArgument = OSCNullArgument()
    #expect(nullArgument.typeTag == .null)
}
