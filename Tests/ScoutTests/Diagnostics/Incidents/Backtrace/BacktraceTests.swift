//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout

@Suite("Backtrace")
struct BacktraceTests {
    let app = LoadedImage(name: "MyApp", base: 0x1_0000_0000, size: 0x10000, uuid: UUID(uuidString: "4F2A1C9E-7B3D-3A11-8E5C-2D9F6B1AC19E"))
    let kit = LoadedImage(name: "UIKitCore", base: 0x1_8000_0000, size: 0x10000, uuid: nil)

    @Test("Addresses become offsets into the image that holds them")
    func addressOffsets() {
        let backtrace = Backtrace(addresses: [0x1_0000_0010, 0x1_8000_0200, 0x1_0000_0300], images: [app, kit])

        #expect(backtrace.images == [Backtrace.Image(name: "MyApp", uuid: app.uuid), Backtrace.Image(name: "UIKitCore", uuid: nil)])
        #expect(backtrace.threads.count == 1)
        #expect(backtrace.threads[0].attributed)
        #expect(
            backtrace.threads[0].frames == [
                Backtrace.Frame(image: 0, offset: 0x10),
                Backtrace.Frame(image: 1, offset: 0x200),
                Backtrace.Frame(image: 0, offset: 0x300),
            ]
        )
    }

    @Test("An address outside every image keeps the raw address")
    func unknownAddress() {
        let backtrace = Backtrace(addresses: [0xDEAD_0000], images: [app])

        #expect(backtrace.images.isEmpty)
        #expect(backtrace.threads[0].frames == [Backtrace.Frame(image: nil, offset: 0xDEAD_0000)])
    }

    @Test("A frame encodes as an image index and offset pair")
    func compactCoding() throws {
        let backtrace = Backtrace(addresses: [0x1_0000_0010, 0xDEAD_0000], images: [app])

        let data = try JSONEncoder().encode(backtrace)
        let json = try #require(String(data: data, encoding: .utf8))

        #expect(json.contains("[0,16]"))
        #expect(json.contains("[3735879680]"))
        #expect(try JSONDecoder().decode(Backtrace.self, from: data) == backtrace)
    }

    @Test("MetricKit threads keep their binary UUIDs and share one image table")
    func metricKitStacks() throws {
        let backtrace = try MetricKitStackTree(json: Data(crashTreeJSON.utf8)).backtrace

        #expect(backtrace.threads.map(\.attributed) == [false, true])
        #expect(backtrace.images.map(\.name) == ["libsystem_kernel.dylib", "MyApp", "UIKitCore"])
        #expect(backtrace.images[1].uuid == UUID(uuidString: "4F2A1C9E-7B3D-3A11-8E5C-2D9F6B1AC19E"))
        #expect(
            backtrace.threads[1].frames == [
                Backtrace.Frame(image: 1, offset: 107_248),
                Backtrace.Frame(image: 2, offset: 5000),
                Backtrace.Frame(image: 1, offset: 2000),
            ]
        )
    }

    @Test("A MetricKit frame without a binary falls back to its address")
    func metricKitUnknownFrame() throws {
        let json = """
            {"callStacks": [{"threadAttributed": true, "callStackRootFrames": [{"sampleCount": 1, "address": 4096}]}]}
            """

        let backtrace = try MetricKitStackTree(json: Data(json.utf8)).backtrace

        #expect(backtrace.threads[0].frames == [Backtrace.Frame(image: nil, offset: 4096)])
    }

    @Test("The image this code runs in reports its UUID")
    func loadedImageUUID() throws {
        let base = UInt64(UInt(bitPattern: #dsohandle))
        let image = try #require(LoadedImage.loaded().first { $0.base == base })

        #expect(image.uuid != nil)
        #expect(image.size > 0)
    }
}
