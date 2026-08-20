//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

struct IncidentArchive<Payload: Codable & Sendable> {
    typealias Persist = @Sendable (Payload, UUID, UUID, NSManagedObjectContext) throws -> Void

    let folder: String
    let pathExtension: String
    let persist: Persist
    var fileManager: FileManager = .default

    private var directory: URL {
        fileManager.scoutDirectory(folder)
    }

    func write(_ payload: Payload) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(payload)
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

            let fileName = "\(UUID().uuidString).\(pathExtension)"
            let fileURL = directory.appendingPathComponent(fileName)

            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to archive \(pathExtension): \(error)")
        }
    }

    func flush(deviceID: UUID) async {
        guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for file in files where file.pathExtension == pathExtension {
            guard let data = try? Data(contentsOf: file) else {
                try? fileManager.removeItem(at: file)
                continue
            }

            guard let payload = try? decoder.decode(Payload.self, from: data) else {
                try? fileManager.removeItem(at: file)
                continue
            }

            do {
                let id = UUID(uuidString: file.deletingPathExtension().lastPathComponent) ?? UUID()
                try await persistentContainer.performBackgroundTask { context in
                    context.mergePolicy = NSMergePolicy.scout
                    try persist(payload, id, deviceID, context)
                }
                try fileManager.removeItem(at: file)
            } catch {
                print("Failed to process \(pathExtension): \(error)")
            }
        }
    }
}

extension FileManager {
    fileprivate func scoutDirectory(_ folder: String) -> URL {
        urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Scout/\(folder)", isDirectory: true)
    }
}
