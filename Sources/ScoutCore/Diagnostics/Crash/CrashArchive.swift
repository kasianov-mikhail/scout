//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

// Crash data is written synchronously to disk to ensure it's saved before the
// application terminates.
struct CrashArchive {
    private let archive: IncidentArchive<CrashInfo>

    init(directory: URL) {
        archive = IncidentArchive(directory: directory, pathExtension: "crash", persist: logCrash)
    }

    static let system = CrashArchive(
        directory: FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Scout/Crashes", isDirectory: true)
    )

    func write(_ crash: CrashInfo) {
        archive.write(crash)
    }

    func flush(deviceID: UUID) async {
        await archive.flush(deviceID: deviceID)
    }
}
