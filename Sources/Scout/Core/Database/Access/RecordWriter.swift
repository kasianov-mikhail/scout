//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol RecordWriter: Sendable {
    func write(record: Record) async throws
    func write(records: [Record]) async throws
}

struct RecordConflictError: LocalizedError {
    let serverRecord: Record
    let errorDescription: String? = "The record was changed on the server"
}
