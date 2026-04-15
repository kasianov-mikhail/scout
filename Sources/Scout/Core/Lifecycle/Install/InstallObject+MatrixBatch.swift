//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension InstallObject: MatrixBatch {
    static func matrix(of batch: [InstallObject]) throws(MatrixPropertyError) -> GridMatrix<Int> {
        guard let week = batch.first?.week else {
            throw .init("week")
        }
        return Matrix(
            recordType: Int.recordType,
            date: week,
            name: "Install",
            cells: parse(of: batch)
        )
    }

    static func parse(of batch: [InstallObject]) -> [GridCell<Int>] {
        batch.grouped(by: \.date).mapValues(\.count).map(Cell.init)
    }
}
