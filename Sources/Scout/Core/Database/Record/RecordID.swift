//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A backend-neutral record identifier — the counterpart of `CKRecord.ID`.
///
/// Scout names every record by a single string (a UUID or a stable object
/// URI), so the identifier carries nothing more than that name.
///
struct RecordID: Hashable, Sendable {
    let recordName: String
}
