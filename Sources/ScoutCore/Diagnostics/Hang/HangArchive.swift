//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

// Hang data is written synchronously to disk from the watchdog thread so a
// report survives even if the watchdog terminates the app afterward.
struct HangArchive {
    private let archive: IncidentArchive<HangInfo>

    init(directory: URL) {
        archive = IncidentArchive(directory: directory, pathExtension: "hang", persist: logHang)
    }

    static let system = HangArchive(
        directory: FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Scout/Hangs", isDirectory: true)
    )

    func write(_ hang: HangInfo) {
        archive.write(hang)
    }

    func flush(deviceID: UUID) async {
        await archive.flush(deviceID: deviceID)
    }
}
