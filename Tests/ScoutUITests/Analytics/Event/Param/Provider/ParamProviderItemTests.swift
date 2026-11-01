//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

@Suite("Param item")
struct ParamProviderItemTests {
    @Test("The payload decodes to keyed values")
    func decodes() throws {
        let data = Data(#"{"product_id":"com.scout.pro","price":"49.99","currency":"USD"}"#.utf8)

        let items = try ParamProvider.Item.fromData(data)

        #expect(
            Dictionary(uniqueKeysWithValues: items.map { ($0.key, $0.value) }) == [
                "currency": "USD",
                "price": "49.99",
                "product_id": "com.scout.pro",
            ])
    }

    @Test("An empty payload decodes to no items")
    func emptyPayload() throws {
        let items = try ParamProvider.Item.fromData(Data("{}".utf8))

        #expect(items.isEmpty)
    }

    @Test("Malformed JSON throws")
    func malformedPayload() {
        #expect(throws: DecodingError.self) {
            try ParamProvider.Item.fromData(Data("not json".utf8))
        }
    }

    @Test("A non-string value throws")
    func nonStringValue() {
        #expect(throws: DecodingError.self) {
            try ParamProvider.Item.fromData(Data(#"{"count":3}"#.utf8))
        }
    }

    @Test("An item prints as its key and value")
    func description() {
        #expect(ParamProvider.Item(key: "price", value: "49.99").description == "price: 49.99")
    }

    @Test("Items order by key only")
    func sorting() {
        #expect(ParamProvider.Item(key: "b", value: "1") < ParamProvider.Item(key: "c", value: "0"))
        #expect(ParamProvider.Item(key: "b", value: "2") >= ParamProvider.Item(key: "b", value: "1"))
    }
}
