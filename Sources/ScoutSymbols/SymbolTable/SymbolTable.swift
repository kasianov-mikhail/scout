//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

package struct SymbolTable: Equatable, Sendable {
    package let uuid: UUID
    package let functions: [Function]
    package let lines: [Line]
    package let inlines: [Inline]

    package init(uuid: UUID, functions: [Function], lines: [Line], inlines: [Inline]) {
        self.uuid = uuid
        self.functions = functions.sorted()
        self.lines = lines.sorted()
        self.inlines = inlines.sorted()
    }

    package struct Location: Hashable, Sendable {
        package let file: String
        package let line: Int

        package init(file: String, line: Int) {
            self.file = file
            self.line = line
        }
    }

    package struct Function: Comparable, Sendable {
        package let start: UInt64
        package let end: UInt64
        package let name: String

        package init(start: UInt64, end: UInt64, name: String) {
            self.start = start
            self.end = end
            self.name = name
        }

        package static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.start < rhs.start
        }
    }

    package struct Line: Comparable, Sendable {
        package let address: UInt64
        package let location: Location?

        package init(address: UInt64, location: Location?) {
            self.address = address
            self.location = location
        }

        package static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.address < rhs.address
        }
    }

    package struct Inline: Comparable, Sendable {
        package let start: UInt64
        package let end: UInt64
        package let depth: Int
        package let name: String
        package let call: Location

        package init(start: UInt64, end: UInt64, depth: Int, name: String, call: Location) {
            self.start = start
            self.end = end
            self.depth = depth
            self.name = name
            self.call = call
        }

        package static func < (lhs: Self, rhs: Self) -> Bool {
            (lhs.start, lhs.depth) < (rhs.start, rhs.depth)
        }
    }

    package struct Frame: Equatable, Sendable {
        package let name: String
        package let location: Location?
    }
}
