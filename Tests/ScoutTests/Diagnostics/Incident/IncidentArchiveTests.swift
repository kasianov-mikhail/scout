//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import Support

private let crashFolder = "Crashes"
private let hangFolder = "Hangs"

@Suite("IncidentArchive")
struct IncidentArchiveTests {
    @Test("write creates the directory and stores the incident")
    func testWriteCreatesFile() throws {
        let fileManager = TemporaryFileManager()

        crashArchive(fileManager).write(makeCrash())

        let files = try fileManager.storedFiles(crashFolder)

        #expect(files.count == 1)
        #expect(files.first?.pathExtension == "crash")
    }

    @Test("write tags files with the archive's path extension")
    func testWriteUsesPathExtension() throws {
        let fileManager = TemporaryFileManager()

        hangArchive(fileManager).write(makeHang())

        let files = try fileManager.storedFiles(hangFolder)

        #expect(files.count == 1)
        #expect(files.first?.pathExtension == "hang")
    }

    @Test("write persists crash data that can be decoded")
    func testWritePersistsDecodableCrash() throws {
        let fileManager = TemporaryFileManager()

        crashArchive(fileManager).write(
            makeCrash(
                name: "NSInvalidArgumentException",
                reason: "Unrecognized selector",
                stackTrace: ["0x1234", "0x5678", "0x9ABC"]
            )
        )

        let file = try #require(try fileManager.storedFiles(crashFolder).first)
        let decoded = try decode(CrashInfo.self, from: file)

        #expect(decoded.name == "NSInvalidArgumentException")
        #expect(decoded.reason == "Unrecognized selector")
        #expect(decoded.stackTrace == ["0x1234", "0x5678", "0x9ABC"])
    }

    @Test("write persists hang data that can be decoded")
    func testWritePersistsDecodableHang() throws {
        let fileManager = TemporaryFileManager()

        hangArchive(fileManager).write(
            makeHang(
                name: "Watchdog Termination Imminent",
                reason: "Main thread unresponsive for 9.8s",
                stackTrace: ["0x1234", "0x5678"],
                duration: 9.8
            )
        )

        let file = try #require(try fileManager.storedFiles(hangFolder).first)
        let decoded = try decode(HangInfo.self, from: file)

        #expect(decoded.name == "Watchdog Termination Imminent")
        #expect(decoded.reason == "Main thread unresponsive for 9.8s")
        #expect(decoded.stackTrace == ["0x1234", "0x5678"])
        #expect(decoded.duration == 9.8)
    }

    @Test("write handles nil reason")
    func testWriteHandlesNilReason() throws {
        let fileManager = TemporaryFileManager()

        crashArchive(fileManager).write(makeCrash(name: "SIGABRT", reason: nil, stackTrace: []))

        let file = try #require(try fileManager.storedFiles(crashFolder).first)
        let decoded = try decode(CrashInfo.self, from: file)

        #expect(decoded.name == "SIGABRT")
        #expect(decoded.reason == nil)
        #expect(decoded.stackTrace.isEmpty)
    }

    @Test("multiple writes create separate files")
    func testMultipleWritesCreateSeparateFiles() throws {
        let fileManager = TemporaryFileManager()
        let archive = crashArchive(fileManager)

        archive.write(makeCrash(name: "Crash1"))
        archive.write(makeCrash(name: "Crash2"))
        archive.write(makeCrash(name: "Crash3"))

        let files = try fileManager.storedFiles(crashFolder)

        #expect(files.count == 3)
        #expect(files.allSatisfy { $0.pathExtension == "crash" })
    }

    private func crashArchive(_ fileManager: FileManager) -> IncidentArchive<CrashInfo> {
        IncidentArchive(
            folder: crashFolder,
            pathExtension: "crash",
            persist: logCrash,
            fileManager: fileManager
        )
    }

    private func hangArchive(_ fileManager: FileManager) -> IncidentArchive<HangInfo> {
        IncidentArchive(
            folder: hangFolder,
            pathExtension: "hang",
            persist: logHang,
            fileManager: fileManager
        )
    }

    private func makeCrash(name: String = "TestException", reason: String? = "Test reason", stackTrace: [String] = ["frame1", "frame2"]) -> CrashInfo {
        CrashInfo(name: name, reason: reason, stackTrace: stackTrace, identity: .stub)
    }

    private func makeHang(name: String = "Main Thread Blocked", reason: String? = "Main thread unresponsive for 4.2s", stackTrace: [String] = ["frame1", "frame2"], duration: TimeInterval = 4.2) -> HangInfo {
        HangInfo(name: name, reason: reason, stackTrace: stackTrace, duration: duration, identity: .stub)
    }

    private func decode<Payload: Decodable>(_ type: Payload.Type, from file: URL) throws -> Payload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: Data(contentsOf: file))
    }
}

private final class TemporaryFileManager: FileManager {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)

    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        [root]
    }

    func storedFiles(_ folder: String) throws -> [URL] {
        let directory = root.appendingPathComponent("Scout/\(folder)", isDirectory: true)
        return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }
}
