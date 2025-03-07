
import Foundation

public struct OSCBundle: OSCPacket {
    public let timetag: OSCTimetag
    public let elements: [OSCPacket]
    
    public init(at timetag: OSCTimetag, with elements: [OSCPacket]) {
        self.timetag = timetag
        self.elements = elements
    }
    
    init(from buffer: [UInt8]) throws {
        guard buffer.count >= 12 && buffer.count % 4 == 0 else {
            throw OSCPacketError.invalidPacket
        }
        guard buffer.starts(with: OSCBundle.bundleString) else {
            throw OSCPacketError.invalidBundleBuffer
        }
        let timetag = try OSCTimetag(from: [UInt8](buffer[8..<16]))
        
        var remainingBuffer = [UInt8](buffer[16...])
        var elements = [OSCPacket]()
        
        while !remainingBuffer.isEmpty {
            let elementLength = remainingBuffer[0..<4].withUnsafeBytes { $0.load(as: Int32.self).bigEndian }
            let offset = 4 + Int(elementLength)
            let elementBuffer = [UInt8](remainingBuffer[4..<offset])
            elements.append(try parseOSCPacket(elementBuffer))
            remainingBuffer = [UInt8](remainingBuffer[offset...])
        }
        
        self.init(at: timetag, with: elements)
    }
    
    public var buffer: [UInt8] {
        let firstPart = OSCBundle.bundleString + timetag.buffer
        let secondPart = elements.map { element in
            let length = Int32(element.buffer.count)
            let lengthBuffer = withUnsafeBytes(of: length.bigEndian) { Array($0) }
            return lengthBuffer + element.buffer
        }.joined()
        return firstPart + secondPart
    }
}

extension OSCBundle {
    static let bundleString = "#bundle".toOSCString()
}
