//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Handles file-based persistence and recovery of hang reports.
///
/// Hang data is written synchronously to disk from the watchdog thread so
/// a report survives even if the watchdog terminates the app afterward.
///
struct HangArchive {
    let directory: URL

    /// The default hang archive using the Application Support directory.
    static let system = HangArchive(
        directory: FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Scout/Hangs", isDirectory: true)
    )

    /// Writes a hang report to disk synchronously.
    func write(_ hang: HangInfo) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(hang) else {
            return
        }

        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let fileName = "\(UUID().uuidString).hang"
        let fileURL = directory.appendingPathComponent(fileName)

        try? data.write(to: fileURL, options: .atomic)
    }

    /// Flushes any pending hang reports from previous sessions.
    ///
    /// Call this method after CoreData is initialized to migrate hang files
    /// into the database for syncing.
    ///
    func flush(deviceID: UUID) async {
        guard let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        else {
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for file in files where file.pathExtension == "hang" {
            guard let data = try? Data(contentsOf: file), let hang = try? decoder.decode(HangInfo.self, from: data)
            else {
                try? FileManager.default.removeItem(at: file)
                continue
            }

            do {
                let id = UUID(uuidString: file.deletingPathExtension().lastPathComponent) ?? UUID()
                try await persistentContainer.performBackgroundTask { context in
                    try logHang(hang, id: id, deviceID: deviceID, context: context)
                }
                try FileManager.default.removeItem(at: file)
            } catch {
                print("Failed to process hang: \(error.localizedDescription)")
            }
        }
    }
}
