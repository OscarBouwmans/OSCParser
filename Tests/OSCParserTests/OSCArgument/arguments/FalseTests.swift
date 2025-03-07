
import Testing
@testable import OSCParser

@Test func oscArgumentFalse() async throws {
    let falseArgument = OSCFalseArgument()
    #expect(falseArgument.typeTag == .false)
}
