//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol CellProtocol: Combining, Sendable, Equatable {
    associatedtype Scalar: MetricScalar

    static var recordType: String { get }

    var key: String { get }
    var value: Scalar { get }

    init(key: String, value: Scalar) throws
}

extension String {
    var fields: (String, String) {
        get throws(CellKeyError) {
            let parts = components(separatedBy: "_")
            guard parts.count == 3 else {
                throw .malformed(self)
            }
            guard parts[0] == "cell" else {
                throw .prefix(expected: "cell", found: parts[0])
            }
            return (parts[1], parts[2])
        }
    }
}

enum CellKeyError: LocalizedError {
    case malformed(String)
    case mismatch(field: String, value: String)
    case prefix(expected: String, found: String)

    var errorDescription: String? {
        switch self {
        case .malformed(let key):
            "Malformed cell key: \(key)"
        case .mismatch(let field, let value):
            "Invalid \(field) in cell key: \(value)"
        case .prefix(let expected, let found):
            "Expected prefix '\(expected)' but found '\(found)' in cell key"
        }
    }
}

extension Int {
    var leadingZero: String {
        String(format: "%02d", self)
    }
}
