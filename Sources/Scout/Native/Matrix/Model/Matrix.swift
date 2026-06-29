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

    static var sampleRecords: [Record] {
        []
    }

    static var desiredKeys: [String] {
        ["date", "name", "category", "app_version"]
    }
}

extension Matrix: Combining {
    func isDuplicate(of other: Matrix<T>) -> Bool {
        date == other.date
            && name == other.name
            && category == other.category
            && version == other.version
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
        lhs.date == rhs.date
            && lhs.name == rhs.name
            && lhs.category == rhs.category
            && lhs.version == rhs.version
            && lhs.cells == rhs.cells
    }
}
