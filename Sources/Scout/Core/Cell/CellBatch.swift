//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol CellBatch {
    associatedtype Cell: CellProtocol
    static func parse(of batch: [Self]) -> [Cell]
}
