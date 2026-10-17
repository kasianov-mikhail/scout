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

    var directory: URL {
        fileManager.scoutDirectory(folder)
    }

    func write(_ payload: Payload, id: UUID = UUID()) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(payload)
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

            let fileName = "\(id.uuidString).\(pathExtension)"
            let fileURL = directory.appendingPathComponent(fileName)

            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to archive \(pathExtension): \(error)")
        }
    }

    var files: [URL] {
        guard fileManager.fileExists(atPath: directory.path) else {
            return []
        }

        do {
            return try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        } catch {
            print("Failed to list \(pathExtension) files: \(error)")
            return []
        }
    }

    func remove(file: URL) {
        do {
            try fileManager.removeItem(at: file)
        } catch {
            print("Failed to remove \(file.lastPathComponent): \(error)")
        }
    }

    func flush(deviceID: UUID) async {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for file in files where file.pathExtension == pathExtension {
            let data: Data
            do {
                data = try Data(contentsOf: file)
            } catch {
                print("Failed to read \(file.lastPathComponent), removing it: \(error)")
                remove(file: file)
                continue
            }

            let payload: Payload
            do {
                payload = try decoder.decode(Payload.self, from: data)
            } catch {
                print("Failed to decode \(file.lastPathComponent), removing it: \(error)")
                remove(file: file)
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
