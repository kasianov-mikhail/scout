//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol RecordLocator {
    func lookup(recordName: String, fields: [String]?) async throws -> Record
}

struct RecordNotFoundError: LocalizedError {
    let errorDescription: String? = "No record found for the requested identifier"
}
