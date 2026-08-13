//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

// Crash data is written synchronously to disk to ensure it's saved before the
// application terminates.
struct CrashArchive {
    private let archive: IncidentArchive<CrashInfo>

    let directory: URL

    init(directory: URL) {
        self.directory = directory
        archive = IncidentArchive(directory: directory, pathExtension: "crash", persist: logCrash)
    }

    static let systemDirectory = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .first!
        .appendingPathComponent("Scout/Crashes", isDirectory: true)

    static let system = CrashArchive(directory: systemDirectory)

    func write(_ crash: CrashInfo) {
        archive.write(crash)
    }

    func flush(deviceID: UUID) async {
        convertRawReports()
        await archive.flush(deviceID: deviceID)
    }

    // The signal handler leaves raw reports behind — symbolicating them is
    // not signal-safe, so it happens here, on the launch that finds them.
    // The converted file keeps the raw file's UUID stem: if the process dies
    // between write and remove, the next launch overwrites the same crash
    // instead of duplicating it.
    func convertRawReports() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        else {
            return
        }

        for file in files where file.pathExtension == RawCrashFormat.pathExtension {
            if let data = try? Data(contentsOf: file), let report = RawCrashReport(data: data) {
                let id = UUID(uuidString: file.deletingPathExtension().lastPathComponent) ?? UUID()
                archive.write(report.crashInfo(), id: id)
            }
            try? FileManager.default.removeItem(at: file)
        }
    }
}
