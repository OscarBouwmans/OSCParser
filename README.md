# OSCParser

Pure Swift OSC library for parsing and generating Open Sound Control messages.

## About

OSCParser is a lightweight, dependency-free Swift library that provides tools for working with the Open Sound Control (OSC) protocol. OSC is commonly used for communication between computers, sound synthesizers, and other multimedia devices.

## Features

- Parse incoming OSC messages
- Create and send OSC messages
- Support for standard OSC data types (int32, float32, string, blob)
- Support for OSC bundles
- Swift native implementation

## Networking

This library does not include networking capabilities. It is designed to work with any networking library or framework of your choice.

This library does however include an `encodeSlip` function and `OSCSlipStreamParser` class to handle SLIP streams, as is recommended by the OSC 1.1 specification when using streaming protocols like TCP.

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/username/OSCParser.git", from: "1.0.0")
]
```

## Usage

```swift
import OSCParser

// Create an OSC message
let message = OSCMessage(address: ["hello", "world"], arguments: [
    OSCInt32Argument(value: 42),
])
message.buffer // << Data to send over the network

// Parse an OSC message
let data: [UInt8] = ... // Received data
let packet = try parseOSCPacket(data)

if let bundle = packet as? OSCBundle {
    // Handle OSC bundle
}

if let message = packet as? OSCMessage {
    // Handle OSC message
}
```

## License

MIT

## Contributing

Bug reports and fixes are welcome. Please feel free to report an Issue with reproduction steps, or submit a Pull Request.
