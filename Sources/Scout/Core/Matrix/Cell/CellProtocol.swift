//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A single cell of a matrix: a coordinate key and a scalar value.
protocol CellProtocol: Combining, Sendable, Equatable {
    associatedtype Scalar: MatrixValue

    var key: String { get }
    var value: Scalar { get }

    init(key: String, value: Scalar) throws
}

/// An unparseable cell key from a CloudKit record.
///
/// Thrown for a malformed or hostile record in the public database, and
/// surfaced through `Matrix.init(record:)` so callers can reject the record
/// instead of crashing the host app.
///
enum CellKeyError: LocalizedError {
    case malformed(String)
    case invalidComponent(field: String, value: String)

    var errorDescription: String? {
        switch self {
        case .malformed(let key):
            "Malformed cell key: \(key)"
        case .invalidComponent(let field, let value):
            "Invalid \(field) in cell key: \(value)"
        }
    }
}

extension Int {
    var leadingZero: String {
        String(format: "%02d", self)
    }
}

// MARK: - Debug

extension Array where Element: CellProtocol {
    var summary: String {
        if isEmpty {
            return "[]"
        }
        let items = map { cell in
            "\(cell.key)=\(String(describing: cell.value))"
        }
        return "[\(items.joined(separator: ", "))]"
    }
}
