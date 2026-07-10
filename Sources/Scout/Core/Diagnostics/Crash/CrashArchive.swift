//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Handles file-based persistence and recovery of crash reports.
///
/// Crash data is written synchronously to disk to ensure it's saved
/// before the application terminates.
///
struct CrashArchive {
    let directory: URL

    static let system = CrashArchive(
        directory: FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Scout/Crashes", isDirectory: true)
    )

    func write(_ crash: CrashInfo) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(crash) else {
            return
        }

        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let fileName = "\(UUID().uuidString).crash"
        let fileURL = directory.appendingPathComponent(fileName)

        try? data.write(to: fileURL, options: .atomic)
    }

    func flush(deviceID: UUID) async {
        guard let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for file in files where file.pathExtension == "crash" {
            guard let data = try? Data(contentsOf: file), let crash = try? decoder.decode(CrashInfo.self, from: data) else {
                try? FileManager.default.removeItem(at: file)
                continue
            }

            do {
                let id = UUID(uuidString: file.deletingPathExtension().lastPathComponent) ?? UUID()
                try await persistentContainer.performBackgroundTask { context in
                    try logCrash(crash, id: id, deviceID: deviceID, context: context)
                }
                try FileManager.default.removeItem(at: file)
            } catch {
                print("Failed to process crash: \(error.localizedDescription)")
            }
        }
    }
}
