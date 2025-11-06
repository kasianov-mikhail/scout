//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension EventObject: MatrixBatch {
    static func matrix(of batch: [EventObject]) throws(MatrixPropertyError) -> GridMatrix<Int> {
        guard let name = batch.first?.name else {
            throw .init("name")
        }
        guard let week = batch.first?.week else {
            throw .init("week")
        }
        return Matrix(
            recordType: "DateIntMatrix",
            date: week,
            name: name,
            cells: parse(of: batch)
        )
    }
}
