
public func encodeSlip(buffer: [UInt8], mode: SlipMode = .endOnBothSides) -> [UInt8] {
    let END: UInt8 = 0xC0
    let ESC: UInt8 = 0xDB
    let ESC_END: UInt8 = 0xDC
    let ESC_ESC: UInt8 = 0xDD
    
    switch mode {
    case .endOnBothSides:
        var encodedBuffer: [UInt8] = []
        encodedBuffer.append(END)
        for byte in buffer {
            switch byte {
            case END:
                encodedBuffer.append(ESC)
                encodedBuffer.append(ESC_END)
            case ESC:
                encodedBuffer.append(ESC)
                encodedBuffer.append(ESC_ESC)
            default:
                encodedBuffer.append(byte)
            }
        }
        encodedBuffer.append(END)
        return encodedBuffer
    }
}

public enum SlipMode {
    case endOnBothSides
}
