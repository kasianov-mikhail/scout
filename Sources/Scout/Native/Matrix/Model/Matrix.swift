//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Matrix<T: CellProtocol> {
    let date: Date
    let name: String
    var category: String?
    var version: String?
    var baseRecord: Record?
    let cells: [T]
}

extension Matrix: RecordDecodable {
    static var recordType: String {
        T.recordType
    }

    static var desiredKeys: [String] {
        ["date", "name", "category", "app_version"]
    }
}

extension Matrix: Combining {
    struct MergeKey: Hashable {
        let date: Date
        let name: String
        let category: String?
        let version: String?
    }

    var mergeKey: MergeKey {
        MergeKey(date: date, name: name, category: category, version: version)
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        Matrix(
            date: lhs.date,
            name: lhs.name,
            category: lhs.category,
            version: lhs.version,
            baseRecord: lhs.baseRecord ?? rhs.baseRecord,
            cells: (lhs.cells + rhs.cells).mergeDuplicates()
        )
    }
}

extension Matrix: Equatable {
    static func == (lhs: Matrix<T>, rhs: Matrix<T>) -> Bool {
        lhs.isDuplicate(of: rhs) && lhs.cells == rhs.cells
    }
}
