//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// An abstraction over a CloudKit-backed record store.
///
/// The `Database` protocol provides a minimal, async API for persisting and
/// querying `CKRecord` values. It is designed to be implemented by concrete
/// types that wrap `CKDatabase` (e.g., private, public, or shared databases),
/// as well as by test doubles for unit testing.
///
protocol Database: Sendable {

    /// Saves or updates a single record in the backing store.
    ///
    func store(record: CKRecord) async throws

    /// Saves or updates multiple records in the backing store.
    ///
    func store(records: [CKRecord]) async throws

    /// Fetches all records that match the given query.
    ///
    /// Implementations must page through all results until completion and
    /// return the full set of matching records.
    ///
    func fetchAll(matching query: CKQuery, fields: [CKRecord.FieldKey]?) async throws -> [CKRecord]
}
