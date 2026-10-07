//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@available(iOS 18, macOS 15, *)
extension CachedDatabase: DatabaseWriter {
    func write(record: Record) async throws {
        try await base.write(record: record)
    }

    func write(records: [Record]) async throws {
        try await base.write(records: records)
    }
}
