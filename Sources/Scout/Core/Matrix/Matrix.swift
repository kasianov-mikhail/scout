//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct Matrix<T: CellProtocol & Combining & Sendable> {
    let recordType: String
    let date: Date
    let name: String
    let category: String?
    let recordID: CKRecord.ID
    let cells: [T]

    func lookupExisting(in database: Database) async throws -> Self? {
        let name = NSPredicate(format: "name == %@", name)
        let date = NSPredicate(format: "date == %@", date as NSDate)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [name, date])
        let query = CKQuery(recordType: recordType, predicate: predicate)

        let matrices = try await database.allRecords(matching: query, desiredKeys: nil)
        let matrix = try matrices.randomElement().map(Matrix.init(record:))

        return matrix
    }
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
          cells: \(cellsSummary))
        """
    }

    private var cellsSummary: String {
        if cells.isEmpty {
            return "[]"
        }
        let items = cells.map { cell in
            "\(cell.key)=\(String(describing: cell.value))"
        }
        return "[\(items.joined(separator: ", "))]"
    }
}
