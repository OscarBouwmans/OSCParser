
import Testing
@testable import OSCParser

@Test func oscArgumentImpulse() async throws {
    let impulseArgument = OSCImpulseArgument()
    #expect(impulseArgument.typeTag == .impulse)
}
