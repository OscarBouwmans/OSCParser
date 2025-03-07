
public protocol OSCArgument: Sendable, Equatable {
    var typeTag: OSCTypeTag { get }
}

public protocol OSCArgumentWithData: OSCArgument {
    associatedtype ArgumentType
    var value: ArgumentType { get }
    var buffer: [UInt8] { get }
    
    init(value: ArgumentType)
    init(from buffer: [UInt8]) throws
}

public enum OSCTypeTag: Character, Sendable {
    case int32 = "i"
    case float32 = "f"
    case string = "s"
    case blob = "b"
    case `true` = "T"
    case `false` = "F"
    case null = "N"
    case impulse = "I"
    case timetag = "t"
}
