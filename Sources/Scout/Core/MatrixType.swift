//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.


/// A protocol that defines the requirements for a matrix type.
///
/// Conforming types must provide a static `recordName` property that specifies the
/// name of the CloudKit record type used to store the matrix data.
///
protocol MatrixType {
    static var recordName: String { get }
}

extension Int: MatrixType {
    static let recordName = "DateIntMatrix"
}

extension Double: MatrixType {
    static let recordName = "DateDoubleMatrix"
}
