//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

typealias AppDatabase = Database & RecordLookup & Sendable

protocol RecordLookup {
    func lookup(id: CKRecord.ID) async throws -> CKRecord
}

extension EnvironmentValues {
    @Entry var database: AppDatabase = DefaultDatabase()
}

extension CKDatabase: RecordLookup {
    func lookup(id: CKRecord.ID) async throws -> CKRecord {
        try await record(for: id)
    }
}
