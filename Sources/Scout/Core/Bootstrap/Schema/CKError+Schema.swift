//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKError {

    /// Returns `true` when the error indicates the CloudKit schema
    /// is missing or outdated (e.g. unknown record type, missing indexes).
    var isSchemaError: Bool {
        switch code {
        case .unknownItem:
            let message = localizedDescription.lowercased()
            return message.contains("record type")
        case .invalidArguments, .serverRejectedRequest:
            let message = localizedDescription.lowercased()
            return message.contains("record type")
                || message.contains("field")
                || message.contains("not marked queryable")
        default:
            return false
        }
    }
}
