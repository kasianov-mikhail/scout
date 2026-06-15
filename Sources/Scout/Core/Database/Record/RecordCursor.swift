//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// An opaque continuation token a backend produces to resume one of its own
/// paginated reads.
///
/// CloudKit's `CKQueryOperation.Cursor` conforms in the CloudKit adapter,
/// keeping its type out of the neutral layer.
///
protocol RecordCursorToken: AnyObject {}

/// A backend-neutral continuation point for paginated reads.
///
/// CloudKit hands back an opaque cursor object; Scout servers return an opaque
/// token string. Each `RecordReader` only ever receives cursors it produced
/// itself, since paginated reads always continue on the database that started
/// them.
///
enum RecordCursor: @unchecked Sendable {
    case opaque(any RecordCursorToken)
    case server(String)
}

/// The continuation was produced by a different backend than the one
/// asked to resume from it.
///
struct CursorMismatchError: LocalizedError {
    let errorDescription: String? = "The pagination cursor belongs to a different backend"
}
