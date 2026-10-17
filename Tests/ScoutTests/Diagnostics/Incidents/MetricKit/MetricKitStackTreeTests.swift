//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("MetricKitStackTree")
struct MetricKitStackTreeTests {
    @Test("The crashed thread's frames come out innermost first")
    func crashedThreadFrames() throws {
        let tree = try MetricKitStackTree(json: Data(crashTreeJSON.utf8))

        let frames = tree.crashedFrames.map { "\($0.binary) + \($0.offset)" }

        #expect(frames == ["MyApp + 0x1a2f0", "UIKitCore + 0x1388", "MyApp + 0x7d0"])
    }

    @Test("Without an attributed thread the first stack stands in")
    func firstStackWithoutAttribution() throws {
        let json = """
            {"callStacks": [
                {"callStackRootFrames": [{"binaryName": "Foundation", "offsetIntoBinaryTextSegment": 16}]},
                {"callStackRootFrames": [{"binaryName": "MyApp", "offsetIntoBinaryTextSegment": 32}]}
            ]}
            """

        let tree = try MetricKitStackTree(json: Data(json.utf8))

        #expect(tree.crashedFrames.map(\.binary) == ["Foundation"])
    }

    @Test("A frame without a binary name or offset reads as unknown")
    func unknownFrame() throws {
        let json = """
            {"callStacks": [{"threadAttributed": true, "callStackRootFrames": [{"sampleCount": 1}]}]}
            """

        let frame = try #require(try MetricKitStackTree(json: Data(json.utf8)).crashedFrames.first)

        #expect(frame.binary == "???")
        #expect(frame.offset == "???")
    }

    @Test("A tree without call stacks has no frames")
    func emptyTree() throws {
        let tree = try MetricKitStackTree(json: Data(#"{"callStacks": []}"#.utf8))

        #expect(tree.crashedFrames.isEmpty)
    }

    @Test("Malformed JSON throws")
    func malformedJSON() {
        #expect(throws: DecodingError.self) {
            try MetricKitStackTree(json: Data("{".utf8))
        }
    }
}

let crashTreeJSON = """
    {
        "callStackPerThread": true,
        "callStacks": [
            {
                "threadAttributed": false,
                "callStackRootFrames": [
                    {"binaryName": "libsystem_kernel.dylib", "binaryUUID": "B0B2E7A4-1C1F-3E37-9A5F-0C1E2D3F4A5B", "offsetIntoBinaryTextSegment": 4660, "sampleCount": 1, "address": 7700000000}
                ]
            },
            {
                "threadAttributed": true,
                "callStackRootFrames": [
                    {
                        "binaryName": "MyApp", "binaryUUID": "4F2A1C9E-7B3D-3A11-8E5C-2D9F6B1AC19E", "offsetIntoBinaryTextSegment": 107248, "sampleCount": 1, "address": 4300000000,
                        "subFrames": [
                            {
                                "binaryName": "UIKitCore", "binaryUUID": "9C1D2E3F-4A5B-3C6D-8E7F-0A1B2C3D4E5F", "offsetIntoBinaryTextSegment": 5000, "sampleCount": 1, "address": 7800000000,
                                "subFrames": [
                                    {"binaryName": "MyApp", "binaryUUID": "4F2A1C9E-7B3D-3A11-8E5C-2D9F6B1AC19E", "offsetIntoBinaryTextSegment": 2000, "sampleCount": 1, "address": 4300000100}
                                ]
                            }
                        ]
                    }
                ]
            }
        ]
    }
    """
