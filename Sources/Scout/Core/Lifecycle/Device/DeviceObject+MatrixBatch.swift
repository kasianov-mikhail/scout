//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension DeviceObject: MatrixBatch {
    static func matrix(of batch: [DeviceObject]) throws(MatrixPropertyError) -> GridMatrix<Int> {
        guard let week = batch.first?.week else {
            throw .init("week")
        }
        return Matrix(
            recordType: Int.recordType,
            date: week,
            name: "Device",
            cells: parse(of: batch)
        )
    }

    static func parse(of batch: [DeviceObject]) -> [GridCell<Int>] {
        batch.grouped(by: \.date).mapValues(\.count).map(Cell.init)
    }
}
