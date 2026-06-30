//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol GridBatch: MatrixBatch {
    static var recordType: String { get }
}

extension DeviceObject: GridBatch {}
extension InstallObject: GridBatch {}
extension LaunchObject: GridBatch {}
extension SessionObject: GridBatch {}
extension VersionObject: GridBatch {}
extension CrashObject: GridBatch {}

extension MatrixBatch where Self: DateObject {
    static func gridCells(of batch: [Self]) throws -> [GridCell<Int>] {
        try batch.grouped(by: \.hour).mapValues(\.count).map(GridCell.init)
    }
}

extension MatrixBatch where Self: DateObject & GridBatch {
    static func matrix(of batch: [Self]) throws -> GridMatrix<Int> {
        try Matrix(
            date: batch.seed(\.week),
            name: Self.recordType,
            cells: gridCells(of: batch)
        )
    }

    static func versionedMatrix(of batch: [Self], appVersion: KeyPath<Self, String?>) throws -> GridMatrix<Int> {
        try Matrix(
            date: batch.seed(\.week),
            name: Self.recordType,
            version: batch.first?[keyPath: appVersion],
            cells: gridCells(of: batch)
        )
    }
}
