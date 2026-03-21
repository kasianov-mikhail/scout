//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("CrashArchive")
struct CrashArchiveTests {
    @Test("write creates directory and crash file")
    func testWriteCreatesCrashFile() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let archive = CrashArchive(directory: tempDir)

        let crash = CrashInfo(
            name: "TestException",
            reason: "Test reason",
            stackTrace: ["frame1", "frame2"]
        )

        archive.write(crash)

        let files = try FileManager.default.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: nil
        )

        #expect(files.count == 1)
        #expect(files.first?.pathExtension == "crash")

        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test("write persists crash data that can be decoded")
    func testWritePersistsDecodableData() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let archive = CrashArchive(directory: tempDir)

        let crash = CrashInfo(
            name: "NSInvalidArgumentException",
            reason: "Unrecognized selector",
            stackTrace: ["0x1234", "0x5678", "0x9ABC"]
        )

        archive.write(crash)

        let files = try FileManager.default.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: nil
        )
        let fileURL = try #require(files.first)
        let data = try Data(contentsOf: fileURL)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(CrashInfo.self, from: data)

        #expect(decoded.name == "NSInvalidArgumentException")
        #expect(decoded.reason == "Unrecognized selector")
        #expect(decoded.stackTrace == ["0x1234", "0x5678", "0x9ABC"])

        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test("write handles nil reason")
    func testWriteHandlesNilReason() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let archive = CrashArchive(directory: tempDir)

        let crash = CrashInfo(
            name: "SIGABRT",
            reason: nil,
            stackTrace: []
        )

        archive.write(crash)

        let files = try FileManager.default.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: nil
        )
        let fileURL = try #require(files.first)
        let data = try Data(contentsOf: fileURL)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(CrashInfo.self, from: data)

        #expect(decoded.name == "SIGABRT")
        #expect(decoded.reason == nil)
        #expect(decoded.stackTrace.isEmpty)

        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test("multiple writes create separate files")
    func testMultipleWritesCreateSeparateFiles() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let archive = CrashArchive(directory: tempDir)

        let crash1 = CrashInfo(name: "Crash1", reason: nil, stackTrace: [])
        let crash2 = CrashInfo(name: "Crash2", reason: nil, stackTrace: [])
        let crash3 = CrashInfo(name: "Crash3", reason: nil, stackTrace: [])

        archive.write(crash1)
        archive.write(crash2)
        archive.write(crash3)

        let files = try FileManager.default.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: nil
        )

        #expect(files.count == 3)
        #expect(files.allSatisfy { $0.pathExtension == "crash" })

        // Cleanup
        try? FileManager.default.removeItem(at: tempDir)
    }
}
