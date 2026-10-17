//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct MetricSeriesPointTests {
    @Test("An integer wire value decodes as a double")
    func integerValue() throws {
        let point = try decode(#"{"date": 1000, "value": {"int": 7}}"#)

        #expect(point.date == Date(millisecondsSince1970: 1000))
        #expect(point.value == 7)
    }

    @Test("A double wire value decodes as is")
    func doubleValue() throws {
        let point = try decode(#"{"date": 1000, "value": {"double": 0.25}}"#)

        #expect(point.value == 0.25)
    }

    @Test("A value that is neither an int nor a double is rejected")
    func unknownValue() {
        #expect(throws: DecodingError.self) {
            try decode(#"{"date": 1000, "value": {"text": "x"}}"#)
        }
    }

    private func decode(_ json: String) throws -> MetricSeriesPoint {
        try JSONDecoder().decode(MetricSeriesPoint.self, from: Data(json.utf8))
    }
}
