//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

protocol MatrixValue {
    static var recordName: String { get }
}

extension Int: MatrixValue {
    static let recordName = "DateIntMatrix"
}

extension Double: MatrixValue {
    static let recordName = "DateDoubleMatrix"
}
