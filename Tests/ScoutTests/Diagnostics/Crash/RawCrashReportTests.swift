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
@testable import Support

@Suite("RawCrashReport")
struct RawCrashReportTests {
    let identity = Identity.stub

    func writeRawReport(
        to url: URL, signal: Int32 = SIGSEGV, addresses: [UInt64] = [0x1000, 0x2000],
        images: [RawCrashReport.Image] = []
    ) throws {
        let trailer = RawCrashFormat.trailer(identity: identity, appVersion: "1.2.3", images: images)

        FileManager.default.createFile(atPath: url.path, contents: nil)
        let fd = open(url.path, O_WRONLY)
        try #require(fd >= 0)

        addresses.withUnsafeBufferPointer { frames in
            trailer.withUnsafeBytes { trailerBytes in
                RawCrashFormat.write(
                    fd: fd,
                    signal: signal,
                    time: 1_700_000_000,
                    session: identity.session.current.uuid,
                    frames: frames,
                    trailer: trailerBytes
                )
            }
        }
        close(fd)
    }

    @Test("the handler's file round-trips through the parser")
    func roundTrip() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).rawcrash")
        defer { try? FileManager.default.removeItem(at: url) }

        let images = [RawCrashReport.Image(name: "Fake.dylib", base: 0x1000, size: 0x4000)]
        try writeRawReport(to: url, addresses: [0x1010, 0x2020, 0x3030], images: images)

        let data = try Data(contentsOf: url)
        let report = try #require(RawCrashReport(data: data))

        #expect(report.signal == SIGSEGV)
        #expect(report.date == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(report.sessionID == identity.session.current)
        #expect(report.addresses == [0x1010, 0x2020, 0x3030])
        #expect(report.installID == identity.install)
        #expect(report.launchID == identity.launch)
        #expect(report.deviceID == identity.device)
        #expect(report.appVersion == "1.2.3")
        #expect(report.images.count == 1)
        #expect(report.images.first?.name == "Fake.dylib")
        #expect(report.images.first?.base == 0x1000)
        #expect(report.images.first?.size == 0x4000)
    }

    @Test("truncated data is rejected instead of trapping")
    func truncatedData() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).rawcrash")
        defer { try? FileManager.default.removeItem(at: url) }

        try writeRawReport(to: url)
        let data = try Data(contentsOf: url)

        for length in 0..<data.count {
            #expect(RawCrashReport(data: data.prefix(length)) == nil)
        }
    }

    @Test("an address in an image that is no longer loaded keeps its offset")
    func unloadedImageKeepsOffset() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).rawcrash")
        defer { try? FileManager.default.removeItem(at: url) }

        let images = [RawCrashReport.Image(name: "Gone.dylib", base: 0x1000, size: 0x4000)]
        try writeRawReport(to: url, addresses: [0x1010, 0xDEAD_0000], images: images)

        let data = try Data(contentsOf: url)
        let report = try #require(RawCrashReport(data: data))
        let crash = report.crashInfo()

        #expect(crash.name == "SIGSEGV")
        #expect(crash.reason == "Signal \(SIGSEGV) received")
        #expect(crash.stackTrace.count == 2)
        #expect(crash.stackTrace[0].contains("Gone.dylib"))
        #expect(crash.stackTrace[0].contains("0x10"))
        #expect(crash.stackTrace[1].contains("???"))
    }

    @Test("an address rebased into a loaded image gets symbolicated")
    func loadedImageIsSymbolicated() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).rawcrash")
        defer { try? FileManager.default.removeItem(at: url) }

        // Pretend the crashed process had every image slid up by 0x10000:
        // rebasing must land back on the real image for dladdr to work.
        let current = try #require(RawCrashReport.Image.loaded().first)
        let slid = RawCrashReport.Image(name: current.name, base: current.base + 0x10000, size: current.size)
        try writeRawReport(to: url, addresses: [slid.base + 0x100], images: [slid])

        let data = try Data(contentsOf: url)
        let report = try #require(RawCrashReport(data: data))
        let crash = report.crashInfo()

        #expect(crash.stackTrace.count == 1)
        #expect(crash.stackTrace[0].contains(current.name))
        #expect(!crash.stackTrace[0].contains("???"))
    }

    @Test("the archive converts a raw report into a decodable crash file")
    func archiveConvertsRawReport() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let stem = UUID()
        try writeRawReport(to: tempDir.appendingPathComponent("\(stem.uuidString).rawcrash"), signal: SIGABRT)

        let archive = CrashArchive(directory: tempDir)
        archive.convertRawReports()

        let files = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
        #expect(files.count == 1)

        let file = try #require(files.first)
        #expect(file.pathExtension == "crash")
        #expect(file.deletingPathExtension().lastPathComponent == stem.uuidString)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let crash = try decoder.decode(CrashInfo.self, from: Data(contentsOf: file))
        #expect(crash.name == "SIGABRT")
        #expect(crash.date == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(crash.appVersion == "1.2.3")
        #expect(crash.installID == identity.install)
    }

    @Test("a corrupt raw report is removed without producing a crash file")
    func corruptRawReportIsRemoved() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let url = tempDir.appendingPathComponent("\(UUID().uuidString).rawcrash")
        try Data([0xDE, 0xAD, 0xBE, 0xEF]).write(to: url)

        let archive = CrashArchive(directory: tempDir)
        archive.convertRawReports()

        let files = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
        #expect(files.count == 0)
    }
}
