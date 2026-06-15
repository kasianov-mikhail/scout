//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// No record exists for the requested identifier.
struct RecordNotFoundError: LocalizedError {
    let errorDescription: String? = "No record found for the requested identifier"
}

/// A write lost a race: the backend already holds a newer version of the
/// record, returned here so the caller can merge and retry.
///
/// CloudKit raises this as `serverRecordChanged`; servers upsert and never
/// produce it. The neutral error keeps the conflict-merge path free of
/// CloudKit types.
///
struct RecordConflictError: LocalizedError {
    let serverRecord: Record

    let errorDescription: String? = "The record was changed on the server"
}
