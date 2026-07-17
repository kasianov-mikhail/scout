//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

struct IncidentArchive<Payload: Codable & Sendable> {
    let directory: URL
    let pathExtension: String
    let persist: @Sendable (Payload, UUID, UUID, NSManagedObjectContext) throws -> Void

    func write(_ payload: Payload) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(payload) else {
            return
        }

        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let fileName = "\(UUID().uuidString).\(pathExtension)"
        let fileURL = directory.appendingPathComponent(fileName)

        try? data.write(to: fileURL, options: .atomic)
    }

    func flush(deviceID: UUID) async {
        guard let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        else {
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for file in files where file.pathExtension == pathExtension {
            guard let data = try? Data(contentsOf: file), let payload = try? decoder.decode(Payload.self, from: data)
            else {
                try? FileManager.default.removeItem(at: file)
                continue
            }

            do {
                let id = UUID(uuidString: file.deletingPathExtension().lastPathComponent) ?? UUID()
                try await persistentContainer.performBackgroundTask { context in
                    try persist(payload, id, deviceID, context)
                }
                try FileManager.default.removeItem(at: file)
            } catch {
                print("Failed to process \(pathExtension): \(error.localizedDescription)")
            }
        }
    }
}
