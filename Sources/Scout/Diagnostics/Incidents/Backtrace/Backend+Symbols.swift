//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//
import Foundation

extension Backend {
    func upload(symbols: BundledSymbols, defaults: UserDefaults) async {
        let key = "scout.symbols.\(id).\(symbols.uuid.uuidString)"
        guard !defaults.bool(forKey: key) else {
            return
        }

        do {
            do {
                _ = try await database.lookup(recordName: symbols.uuid.uuidString, fields: ["date"])
            } catch is RecordNotFoundError {
                try await database.write(records: [symbols.file])
                try await database.write(records: [symbols.index])
            }
            defaults.set(true, forKey: key)
        } catch {
            print("Failed to upload symbols to backend \(id): \(error)")
        }
    }
}
