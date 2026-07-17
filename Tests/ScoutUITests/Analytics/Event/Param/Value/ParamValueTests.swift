//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport
@testable import ScoutUI

struct ParamValueTests {
    @Test("Plain text stays a string")
    func plainString() {
        #expect(ParamValue(parsing: "hello world") == .string("hello world"))
    }

    @Test("Empty value stays a string")
    func emptyString() {
        #expect(ParamValue(parsing: "") == .string(""))
    }

    @Test("Integers, decimals, and exponents read as numbers")
    func numbers() {
        #expect(ParamValue(parsing: "200") == .stringConvertible(.number("200")))
        #expect(ParamValue(parsing: "-182.4") == .stringConvertible(.number("-182.4")))
        #expect(ParamValue(parsing: "1e5") == .stringConvertible(.number("1e5")))
    }

    @Test("Number look-alikes stay strings")
    func numberLookalikes() {
        #expect(ParamValue(parsing: "1.2.3") == .string("1.2.3"))
        #expect(ParamValue(parsing: "0x1F") == .string("0x1F"))
        #expect(ParamValue(parsing: "inf") == .string("inf"))
    }

    @Test("Booleans read as booleans")
    func booleans() {
        #expect(ParamValue(parsing: "true") == .stringConvertible(.boolean(true)))
        #expect(ParamValue(parsing: "false") == .stringConvertible(.boolean(false)))
    }

    @Test("UUIDs read as UUIDs")
    func uuid() {
        let text = "7F9C24E5-86B4-4B7A-91D2-3C5A0E8F6D1B"
        #expect(ParamValue(parsing: text) == .stringConvertible(.uuid(text)))
    }

    @Test("URLs with a scheme and host read as URLs")
    func urls() {
        #expect(ParamValue(parsing: "https://example.com/path") == .stringConvertible(.url("https://example.com/path")))
        #expect(ParamValue(parsing: "scout://events/recent") == .stringConvertible(.url("scout://events/recent")))
        #expect(ParamValue(parsing: "com.scout.pro.yearly") == .string("com.scout.pro.yearly"))
    }

    @Test("ISO 8601 dates read as dates")
    func dates() {
        #expect(ParamValue(parsing: "2026-06-11T09:41:00Z") == .stringConvertible(.date("2026-06-11T09:41:00Z")))
        #expect(
            ParamValue(parsing: "2026-06-09T18:25:43.511Z") == .stringConvertible(.date("2026-06-09T18:25:43.511Z")))
    }

    @Test("JSON objects become dictionaries with sorted keys")
    func jsonObject() {
        let value = ParamValue(parsing: #"{"b": "text", "a": 7, "c": true}"#)
        let expected = ParamValue.dictionary([
            ParamValue.Entry(key: "a", value: .stringConvertible(.number("7"))),
            ParamValue.Entry(key: "b", value: .string("text")),
            ParamValue.Entry(key: "c", value: .stringConvertible(.boolean(true))),
        ])
        #expect(value == expected)
    }

    @Test("JSON arrays become arrays")
    func jsonArray() {
        let value = ParamValue(parsing: #"["a", 1, false]"#)
        #expect(value == .array([.string("a"), .stringConvertible(.number("1")), .stringConvertible(.boolean(false))]))
    }

    @Test("Nested containers parse recursively")
    func nested() {
        let value = ParamValue(parsing: #"{"outer": {"inner": [1]}}"#)
        let expected = ParamValue.dictionary([
            ParamValue.Entry(
                key: "outer",
                value: .dictionary([
                    ParamValue.Entry(key: "inner", value: .array([.stringConvertible(.number("1"))]))
                ])
            )
        ])
        #expect(value == expected)
    }

    @Test("Scalar strings inside JSON are classified")
    func nestedScalars() {
        let value = ParamValue(parsing: #"{"link": "https://example.com", "when": "2026-06-11T09:41:00Z"}"#)
        let expected = ParamValue.dictionary([
            ParamValue.Entry(key: "link", value: .stringConvertible(.url("https://example.com"))),
            ParamValue.Entry(key: "when", value: .stringConvertible(.date("2026-06-11T09:41:00Z"))),
        ])
        #expect(value == expected)
    }

    @Test("Malformed JSON stays a string")
    func malformedJSON() {
        #expect(ParamValue(parsing: "{not json}") == .string("{not json}"))
        #expect(ParamValue(parsing: "[1, 2") == .string("[1, 2"))
    }

    @Test("Containers expose their direct children as nodes")
    func nodes() {
        let nodes = ParamValue(parsing: #"{"a": {"b": [5]}}"#).nodes

        #expect(nodes.count == 1)
        #expect(nodes[0].label == "a" && nodes[0].value.isContainer)

        let inner = nodes[0].value.nodes
        #expect(inner.count == 1)
        #expect(inner[0].label == "b" && inner[0].value.isContainer)

        let leaves = inner[0].value.nodes
        #expect(leaves.count == 1)
        #expect(leaves[0].label == "0")
        #expect(leaves[0].value == .stringConvertible(.number("5")))
        #expect(leaves[0].value.nodes.count == 0)
    }

    @Test("Array elements become indexed nodes")
    func arrayNodes() {
        let nodes = ParamValue(parsing: #"["a", "b"]"#).nodes

        #expect(nodes.count == 2)
        #expect(nodes[0].label == "0" && nodes[0].value == .string("a"))
        #expect(nodes[1].label == "1" && nodes[1].value == .string("b"))
    }

    @Test("Scalars produce no nodes")
    func scalarNodes() {
        #expect(ParamValue(parsing: "plain").nodes.count == 0)
    }

    @Test("Text renders scalars verbatim")
    func scalarText() {
        #expect(ParamValue(parsing: "plain").text == "plain")
        #expect(ParamValue(parsing: "182.4").text == "182.4")
        #expect(ParamValue(parsing: "true").text == "true")
        #expect(ParamValue(parsing: "2026-06-11T09:41:00Z").text == "2026-06-11T09:41:00Z")
    }

    @Test("Text renders containers as JSON with sorted keys")
    func containerText() {
        let text = ParamValue(parsing: #"{"b": 2, "a": "x", "c": [true]}"#).text

        #expect(text.hasPrefix("{") && text.hasSuffix("}"))
        #expect(text.contains(#""a" : "x""#))
        #expect(text.contains(#""b" : 2"#))
        #expect(text.contains("true"))
    }

    @Test("Icons cover every kind")
    func icons() {
        #expect(ParamValue(parsing: "plain").icon == .symbol("textformat"))
        #expect(ParamValue(parsing: "42").icon == .symbol("number"))
        #expect(ParamValue(parsing: #"{"a": 1}"#).icon == .symbol("curlybraces"))
        #expect(ParamValue(parsing: "[1]").icon == .text("[ ]"))
    }

    @Test("Summaries digest each case")
    func summaries() {
        #expect(ParamValue(parsing: "plain").summary == "plain")
        #expect(ParamValue(parsing: "42").summary == "42")
        #expect(ParamValue(parsing: #"{"a": 1, "b": 2}"#).summary == "2 pairs")
        #expect(ParamValue(parsing: "[1]").summary == "1 item")
    }
}
