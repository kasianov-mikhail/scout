//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

protocol MatrixAggregator: Sendable {
    func aggregate<C: CellProtocol>(matrix: Matrix<C>) async throws
}

extension CKDatabase: MatrixAggregator {
    func aggregate(matrix: Matrix<some CellProtocol>) async throws {
        try await MatrixUploader(database: self, maxRetry: 3, matrix: matrix).upload()
    }
}
