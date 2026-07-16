//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

protocol RecordWriter: Sendable {
    func write(record: Record) async throws
    func write(records: [Record]) async throws
}

extension RecordWriter {
    // Records are written in batches no larger than this; the backends cap a single
    // save/modify request at 400 records.
    static var maxBatchSize: Int { 400 }
}
