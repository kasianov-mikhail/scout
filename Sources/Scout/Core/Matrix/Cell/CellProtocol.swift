//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A single cell of a `Matrix`: a stringly-typed coordinate `key`
/// (e.g. `"cell_3_14"`) plus a `value` of scalar type `Scalar`.
///
/// CloudKit records store cells as one flat field per cell keyed by
/// `key`, so `init(key:value:)` parses the coordinate back from the
/// string when reading a matrix.
///
protocol CellProtocol: Combining, Sendable, Equatable {
    associatedtype Scalar: MatrixValue

    var key: String { get }
    var value: Scalar { get }

    init(key: String, value: Scalar)
}

/// Splits a cell key like `"cell_X_Y"` into its three components.
///
/// Returns `nil` if the key doesn't have exactly three underscore-separated parts.
///
func parseCellKey(_ key: String) -> (prefix: String, first: String, second: String)? {
    let parts = key.components(separatedBy: "_")
    guard parts.count == 3 else { return nil }
    return (parts[0], parts[1], parts[2])
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
