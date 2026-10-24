//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import SymbolTable

struct IncidentArchive<Payload: IncidentInfo & Codable & Sendable> {
    let folder: String
    let pathExtension: String
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

    private var incidents: [URL] {
        files.filter { $0.pathExtension == pathExtension }
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    /// The launches whose incidents are still waiting to be logged.
    ///
    /// Recovery leaves them open, so purge keeps their records until the incident links to them.
    var launchIDs: Set<UUID> {
        Set(incidents.compactMap { try? decoder.decode(Payload.self, from: Data(contentsOf: $0)).launchID })
    }

    func flush(deviceID: UUID) async {
        let pending = incidents
        guard !pending.isEmpty else { return }

        let decoder = self.decoder
        let symbols = BundledSymbols.main.flatMap(SymbolTable.init(bundled:))

        for file in pending {
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
                let decoded = try decoder.decode(Payload.self, from: data)
                payload = symbols.map(decoded.symbolicated(symbols:)) ?? decoded
            } catch {
                print("Failed to decode \(file.lastPathComponent), removing it: \(error)")
                remove(file: file)
                continue
            }

            do {
                let id = UUID(uuidString: file.deletingPathExtension().lastPathComponent) ?? UUID()
                try await persistentContainer.performBackgroundTask { context in
                    context.mergePolicy = NSMergePolicy.scout
                    try payload.log(id: id, deviceID: deviceID, context: context)
                }
                try fileManager.removeItem(at: file)
            } catch {
                print("Failed to process \(pathExtension): \(error)")
            }
        }
    }
}

extension SymbolTable {
    fileprivate init?(bundled: BundledSymbols) {
        do {
            try self.init(data: bundled.data)
        } catch {
            print("Failed to decode the bundled symbols: \(error)")
            return nil
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
