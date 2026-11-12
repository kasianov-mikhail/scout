//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import ScoutUI

struct ParamRawTests {
    @Test("Items become sorted, two-space-indented JSON")
    func json() {
        let raw = ParamRaw(items: [
            ParamProvider.Item(key: "price", value: "49.99"),
            ParamProvider.Item(key: "currency", value: "USD"),
            ParamProvider.Item(key: "family_shared", value: "false"),
            ParamProvider.Item(
                key: "offer",
                value: #"{"id": "FALL26", "discount": 0.2, "ends_at": "2026-10-31T23:59:59Z"}"#
            ),
            ParamProvider.Item(key: "promo_codes", value: #"["FALL26", "WELCOME"]"#),
            ParamProvider.Item(key: "quantity", value: "1"),
        ])

        let expected = """
            {
              "currency": "USD",
              "family_shared": false,
              "offer": {
                "discount": 0.2,
                "ends_at": "2026-10-31T23:59:59Z",
                "id": "FALL26"
              },
              "price": 49.99,
              "promo_codes": [
                "FALL26",
                "WELCOME"
              ],
              "quantity": 1
            }
            """

        #expect(raw.text == expected)
        #expect(String(raw.attributed.characters) == raw.text)
    }

    @Test("String values keep their slashes")
    func slashes() {
        let raw = ParamRaw(items: [
            ParamProvider.Item(key: "receipt_url", value: "https://buy.itunes.apple.com/verifyReceipt")
        ])

        let expected = """
            {
              "receipt_url": "https://buy.itunes.apple.com/verifyReceipt"
            }
            """

        #expect(raw.text == expected)
    }

    @Test("No items become an empty object")
    func empty() {
        #expect(ParamRaw(items: []).text == "{}")
    }

    @Test("Malformed text is kept as is")
    func malformed() {
        let source = #"{"key": }"#
        let raw = ParamRaw(text: source)

        #expect(raw.text == source)
        #expect(String(raw.attributed.characters) == source)
    }
}
