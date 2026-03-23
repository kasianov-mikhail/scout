//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

struct MatrixValueTests {
    // MARK: - Int conformance

    @Test("Int recordType is DateIntMatrix")
    func intRecordType() {
        #expect(Int.recordType == "DateIntMatrix")
    }

    @Test("Int conforms to AdditiveArithmetic")
    func intAdditiveArithmetic() {
        let a: Int = 3
        let b: Int = 5
        #expect(a + b == 8)
        #expect(b - a == 2)
        #expect(Int.zero == 0)
    }

    @Test("Int conforms to Comparable")
    func intComparable() {
        #expect(1 < 2)
        #expect(!(2 < 1))
    }

    // MARK: - Double conformance

    @Test("Double recordType is DateDoubleMatrix")
    func doubleRecordType() {
        #expect(Double.recordType == "DateDoubleMatrix")
    }

    @Test("Double conforms to AdditiveArithmetic")
    func doubleAdditiveArithmetic() {
        let a: Double = 1.5
        let b: Double = 2.5
        #expect(a + b == 4.0)
        #expect(b - a == 1.0)
        #expect(Double.zero == 0.0)
    }

    @Test("Double conforms to Comparable")
    func doubleComparable() {
        #expect(1.0 < 2.0)
        #expect(!(2.0 < 1.0))
    }
}
