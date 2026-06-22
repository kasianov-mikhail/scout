//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

struct MatrixValueTests {
    @Test("Int recordType is DateIntMatrix")
    func intRecordType() {
        #expect(Int.recordType == "DateIntMatrix")
    }

    @Test("Double recordType is DateDoubleMatrix")
    func doubleRecordType() {
        #expect(Double.recordType == "DateDoubleMatrix")
    }
}
