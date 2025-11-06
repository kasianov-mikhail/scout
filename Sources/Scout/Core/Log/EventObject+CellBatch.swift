//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension EventObject: CellBatch {
    static func parse(of batch: [EventObject]) -> [GridCell<Int>] {
        batch.grouped(by: \.hour).mapValues(\.count).map(Cell.init)
    }
}
