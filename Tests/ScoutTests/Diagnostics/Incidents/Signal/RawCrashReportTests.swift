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
    let fakeUUID = UUID(uuidString: "4F2A1C9E-7B3D-3A11-8E5C-2D9F6B1AC19E")!

    func rawReportData(signal: Int32 = SIGSEGV, addresses: [UInt64] = [0x1000, 0x2000], images: [LoadedImage] = []) throws -> Data {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).rawcrash")
        defer { try? FileManager.default.removeItem(at: url) }

        try writeRawReport(to: url, signal: signal, addresses: addresses, images: images)
        return try Data(contentsOf: url)
    }

    func writeRawReport(to url: URL, signal: Int32 = SIGSEGV, addresses: [UInt64] = [0x1000, 0x2000], images: [LoadedImage] = []) throws {
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
        let images = [LoadedImage(name: "Fake.dylib", base: 0x1000, size: 0x4000, uuid: fakeUUID)]
        let data = try rawReportData(addresses: [0x1010, 0x2020, 0x3030], images: images)
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
        #expect(report.images.first?.uuid == fakeUUID)
    }

    @Test("the converted crash carries the image UUIDs and offsets")
    func crashInfoBacktrace() throws {
        let images = [LoadedImage(name: "Fake.dylib", base: 0x1000, size: 0x4000, uuid: fakeUUID)]
        let data = try rawReportData(addresses: [0x1010, 0xDEAD_0000], images: images)
        let crash = try #require(RawCrashReport(data: data)).crashInfo

        #expect(crash.backtrace?.images == [Backtrace.Image(name: "Fake.dylib", uuid: fakeUUID)])
        #expect(crash.backtrace?.threads.first?.frames == [Backtrace.Frame(image: 0, offset: 0x10), Backtrace.Frame(image: nil, offset: 0xDEAD_0000)])
    }

    @Test("a report written before image UUIDs still parses")
    func versionOneReport() throws {
        var bytes: [UInt8] = []
        func append<T>(_ value: T) {
            withUnsafeBytes(of: value) { bytes += $0 }
        }
        append(RawCrashFormat.magic)
        append(UInt32(1))
        append(SIGSEGV)
        append(Int64(1_700_000_000))
        append(identity.session.current.uuid)
        append(UInt32(1))
        append(UInt64(0x1010))
        append(identity.install.uuid)
        append(identity.launch.uuid)
        append(identity.device.uuid)
        append(UInt32(0))
        append(UInt32(1))
        append(UInt64(0x1000))
        append(UInt64(0x4000))
        append(UInt32(4))
        bytes += Array("Gone".utf8)

        let report = try #require(RawCrashReport(data: Data(bytes)))

        #expect(report.images == [LoadedImage(name: "Gone", base: 0x1000, size: 0x4000, uuid: nil)])
        #expect(report.addresses == [0x1010])
    }

    @Test("truncated data is rejected instead of trapping")
    func truncatedData() throws {
        let data = try rawReportData()

        for length in 0..<data.count {
            #expect(RawCrashReport(data: data.prefix(length)) == nil)
        }
    }

    @Test("an address in an image that is no longer loaded keeps its offset")
    func unloadedImageKeepsOffset() throws {
        let images = [LoadedImage(name: "Gone.dylib", base: 0x1000, size: 0x4000, uuid: nil)]
        let data = try rawReportData(addresses: [0x1010, 0xDEAD_0000], images: images)
        let report = try #require(RawCrashReport(data: data))
        let crash = report.crashInfo

        #expect(crash.name == "SIGSEGV")
        #expect(crash.reason == "Signal \(SIGSEGV) received")
        #expect(crash.stackTrace.count == 2)
        #expect(crash.stackTrace[0].contains("Gone.dylib"))
        #expect(crash.stackTrace[0].contains("0x10"))
        #expect(crash.stackTrace[1].contains("???"))
    }

    @Test("an address rebased into a loaded image gets symbolicated")
    func loadedImageIsSymbolicated() throws {
        // Pretend the crashed process had every image slid up by 0x10000:
        // rebasing must land back on the real image for dladdr to work.
        let current = try #require(LoadedImage.loaded().first)
        let slid = LoadedImage(name: current.name, base: current.base + 0x10000, size: current.size, uuid: current.uuid)
        let data = try rawReportData(addresses: [slid.base + 0x100], images: [slid])
        let report = try #require(RawCrashReport(data: data))
        let crash = report.crashInfo

        #expect(crash.stackTrace.count == 1)
        #expect(crash.stackTrace[0].contains(current.name))
        #expect(!crash.stackTrace[0].contains("???"))
    }

    @Test("an image rebuilt since the crash keeps its offset instead of foreign names")
    func changedImageKeepsOffset() throws {
        let current = try #require(LoadedImage.loaded().first { $0.uuid != nil })
        let rebuilt = LoadedImage(name: current.name, base: current.base + 0x10000, size: current.size, uuid: UUID())
        let data = try rawReportData(addresses: [rebuilt.base + 0x100], images: [rebuilt])
        let crash = try #require(RawCrashReport(data: data)).crashInfo

        #expect(crash.stackTrace == ["0   \(current.name)   + 0x100"])
    }

    @Test("the archive converts a raw report into a decodable crash file")
    func archiveConvertsRawReport() throws {
        let fileManager = TemporaryFileManager()
        let archive = crashArchive(fileManager)
        try fileManager.createDirectory(at: archive.directory, withIntermediateDirectories: true)

        let stem = UUID()
        try writeRawReport(to: archive.directory.appendingPathComponent("\(stem.uuidString).rawcrash"), signal: SIGABRT)

        archive.convertRawReports()

        let files = try fileManager.storedFiles("Crashes")
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
        let fileManager = TemporaryFileManager()
        let archive = crashArchive(fileManager)
        try fileManager.createDirectory(at: archive.directory, withIntermediateDirectories: true)

        let url = archive.directory.appendingPathComponent("\(UUID().uuidString).rawcrash")
        try Data([0xDE, 0xAD, 0xBE, 0xEF]).write(to: url)

        archive.convertRawReports()

        let files = try fileManager.storedFiles("Crashes")
        #expect(files.isEmpty)
    }

    private func crashArchive(_ fileManager: FileManager) -> IncidentArchive<CrashInfo> {
        IncidentArchive(
            folder: "Crashes",
            pathExtension: "crash",
            fileManager: fileManager
        )
    }
}
