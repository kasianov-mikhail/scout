//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("HangArchive")
struct HangArchiveTests {
    @Test("write creates directory and hang file")
    func testWriteCreatesHangFile() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let archive = HangArchive(directory: tempDir)

        let hang = HangInfo(
            name: "Main Thread Blocked",
            reason: "Main thread unresponsive for 4.2s",
            stackTrace: ["frame1", "frame2"],
            duration: 4.2,
            identity: .stub
        )

        archive.write(hang)

        let files = try FileManager.default.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: nil
        )

        #expect(files.count == 1)
        #expect(files.first?.pathExtension == "hang")

        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test("write persists hang data that can be decoded")
    func testWritePersistsDecodableData() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let archive = HangArchive(directory: tempDir)

        let hang = HangInfo(
            name: "Watchdog Termination Imminent",
            reason: "Main thread unresponsive for 9.8s",
            stackTrace: ["0x1234", "0x5678"],
            duration: 9.8,
            identity: .stub
        )

        archive.write(hang)

        let files = try FileManager.default.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: nil
        )
        let fileURL = try #require(files.first)
        let data = try Data(contentsOf: fileURL)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(HangInfo.self, from: data)

        #expect(decoded.name == "Watchdog Termination Imminent")
        #expect(decoded.reason == "Main thread unresponsive for 9.8s")
        #expect(decoded.stackTrace == ["0x1234", "0x5678"])
        #expect(decoded.duration == 9.8)

        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test("multiple writes create separate files")
    func testMultipleWritesCreateSeparateFiles() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let archive = HangArchive(directory: tempDir)

        let hang1 = HangInfo(name: "Hang1", reason: nil, stackTrace: [], duration: 3.1, identity: .stub)
        let hang2 = HangInfo(name: "Hang2", reason: nil, stackTrace: [], duration: 3.2, identity: .stub)
        let hang3 = HangInfo(name: "Hang3", reason: nil, stackTrace: [], duration: 3.3, identity: .stub)

        archive.write(hang1)
        archive.write(hang2)
        archive.write(hang3)

        let files = try FileManager.default.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: nil
        )

        #expect(files.count == 3)
        #expect(files.allSatisfy { $0.pathExtension == "hang" })

        try? FileManager.default.removeItem(at: tempDir)
    }
}
