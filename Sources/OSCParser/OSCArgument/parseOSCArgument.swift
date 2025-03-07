
public func parseOSCArgument(_ typeTag: OSCTypeTag, using buffer: [UInt8]) throws -> (any OSCArgument, bytesUsed: Int) {
    switch typeTag {
    case .int32:
        return (
            try OSCInt32Argument(from: [UInt8](buffer[0..<4])),
            4
        )
    case .float32:
        return (
            try OSCFloat32Argument(from: [UInt8](buffer[0..<4])),
            4
        )
    case .string:
        let argument = try OSCStringArgument(from: buffer)
        return (
            argument,
            argument.buffer.count
        )
    case .blob:
        let argument = try OSCBlobArgument(from: buffer)
        return (
            try OSCBlobArgument(from: buffer),
            argument.buffer.count
        )
    case .true:
        return (
            OSCTrueArgument(),
            0
        )
    case .false:
        return (
            OSCFalseArgument(),
            0
        )
    case .null:
        return (
            OSCNullArgument(),
            0
        )
    case .impulse:
        return (
            OSCImpulseArgument(),
            0
        )
    case .timetag:
        return (
            try OSCTimetagArgument(from: buffer),
            8
        )
    }
}
