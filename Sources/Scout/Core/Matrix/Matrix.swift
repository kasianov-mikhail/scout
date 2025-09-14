//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct Matrix<T: CellProtocol> {
    let recordType: String
    let date: Date
    let name: String
    var category: String? = nil
    var recordID = CKRecord.ID()
    let cells: [T]
}

extension Matrix: Combining {
    func isDuplicate(of other: Matrix<T>) -> Bool {
        return date == other.date
            && name == other.name
            && category == other.category
            && recordType == other.recordType
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        Matrix(
            recordType: lhs.recordType,
            date: lhs.date,
            name: lhs.name,
            category: lhs.category,
            recordID: [lhs.recordID, rhs.recordID].randomElement()!,
            cells: (lhs.cells + rhs.cells).mergeDuplicates()
        )
    }
}

extension Matrix: CustomStringConvertible {
    var description: String {
        """
        Matrix<\(T.self)>(
          type: "\(recordType)",
          date: \(date),
          name: "\(name)",
          category: \(category ?? "nil"),
          id: \(recordID.recordName),
          cells: \(cells.count) items
        )
        """
    }
}

extension Matrix: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        Matrix<\(T.self)>(
          type: \(recordType), 
          date: \(date), 
          name: \(name),
          category: \(category ?? "nil"),
          id: \(recordID.recordName),
          cells: \(cells.summary)
        """
    }
}
