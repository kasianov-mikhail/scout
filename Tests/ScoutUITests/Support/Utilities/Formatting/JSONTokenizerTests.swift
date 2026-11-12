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

struct JSONTokenizerTests {
    @Test("Nested objects and arrays keep every character")
    func nested() {
        let source = #"{"outer": {"inner": [1, 2, 3]}}"#
        let tokens = JSONTokenizer.tokens(of: source)

        #expect(tokens.map(\.text).joined() == source)
        #expect(tokens.filter { $0.kind == .key }.map(\.text) == ["\"outer\"", "\"inner\""])
        #expect(tokens.filter { $0.kind == .number }.map(\.text) == ["1", "2", "3"])
    }

    @Test("Escaped quotes and backslashes stay inside one string")
    func escapedString() {
        let source = #"{"quote": "a \"b\"", "path": "a\\b"}"#
        let tokens = JSONTokenizer.tokens(of: source)

        #expect(tokens.map(\.text).joined() == source)
        #expect(tokens.filter { $0.kind == .string }.map(\.text) == ["\"a \\\"b\\\"\"", "\"a\\\\b\""])
    }

    @Test("Negative, fractional, and exponential numbers read as numbers")
    func numbers() {
        let source = #"{"negative": -3, "fraction": 49.99, "exponent": 1e6}"#
        let tokens = JSONTokenizer.tokens(of: source)

        #expect(tokens.map(\.text).joined() == source)
        #expect(tokens.filter { $0.kind == .number }.map(\.text) == ["-3", "49.99", "1e6"])
    }

    @Test("True, false, and null read as literals")
    func literals() {
        let source = "[true, false, null]"
        let tokens = JSONTokenizer.tokens(of: source)

        #expect(tokens.map(\.text).joined() == source)
        #expect(tokens.filter { $0.kind == .literal }.map(\.text) == ["true", "false", "null"])
    }

    @Test("A key is a string followed by a colon")
    func keyWithSpacesBeforeColon() {
        let source = #"{"key"   : "a:b"}"#
        let tokens = JSONTokenizer.tokens(of: source)

        #expect(tokens.map(\.text).joined() == source)
        #expect(tokens.filter { $0.kind == .key }.map(\.text) == ["\"key\""])
        #expect(tokens.filter { $0.kind == .string }.map(\.text) == ["\"a:b\""])
    }

    @Test("A malformed payload stays one plain token")
    func malformed() {
        let source = #"{"key": }"#

        #expect(JSONTokenizer.tokens(of: source) == [JSONToken(kind: .plain, text: source)])
    }

    @Test("A payload over the highlight limit stays one plain token")
    func largePayload() {
        let source = #"{"key": ""# + String(repeating: "x", count: 100_000) + #""}"#

        #expect(JSONTokenizer.tokens(of: source) == [JSONToken(kind: .plain, text: source)])
    }

    @Test("Punctuation is a single token per character")
    func punctuation() {
        let source = #"{"a": [true]}"#
        let tokens = JSONTokenizer.tokens(of: source)

        #expect(tokens.filter { $0.kind == .punctuation }.map(\.text) == ["{", ":", "[", "]", "}"])
    }
}
