//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

struct ArrayUniqueTests {
    struct Event {
        let name: String
    }

    @Test func `all unique elements within limit`() {
        let events = [
            Event(name: "A"),
            Event(name: "B"),
            Event(name: "C"),
        ]
        let result = events.unique(by: \.name, max: 3)
        #expect(Set(result) == Set(["A", "B", "C"]))
    }

    @Test func `limit unique elements to 3`() {
        let events = [
            Event(name: "A"),
            Event(name: "A"),
            Event(name: "B"),
            Event(name: "B"),
            Event(name: "B"),
            Event(name: "C"),
        ]
        let result = events.unique(by: \.name, max: 3)
        #expect(result == ["B", "A", "C"])
    }

    @Test("f") func `limit unique elements to 2`() {
        let events = [
            Event(name: "A"),
            Event(name: "A"),
            Event(name: "B"),
            Event(name: "B"),
            Event(name: "B"),
            Event(name: "C"),
        ]
        let result = events.unique(by: \.name, max: 2)
        #expect(result == ["B", "A"])
    }

    @Test func `empty array `() {
        let events: [Event] = []
        let result = events.unique(by: \.name, max: 3)
        #expect(result == [])
    }

    @Test func `all elements are the same`() {
        let events = [
            Event(name: "A"),
            Event(name: "A"),
            Event(name: "A"),
        ]
        let result = events.unique(by: \.name, max: 3)
        #expect(result == ["A"])
    }
}
