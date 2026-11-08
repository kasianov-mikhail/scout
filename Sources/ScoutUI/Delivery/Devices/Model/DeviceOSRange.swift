//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct DeviceOSRange: Equatable {
    let versions: [String]

    init(versions: [String]) {
        self.versions = Array(Set(versions.filter { !$0.isEmpty })).sorted { lhs, rhs in
            lhs.compare(rhs, options: .numeric) == .orderedAscending
        }
    }

    var label: String? {
        guard let first = versions.first, let last = versions.last else {
            return nil
        }
        if first == last {
            return first
        }

        let head = Component(string: first)
        let tail = Component(string: last)

        guard head.name == tail.name else {
            return "\(first)–\(last)"
        }

        return [head.name, "\(head.number)–\(tail.number)"].filter { !$0.isEmpty }.joined(separator: " ")
    }

    var shortLabel: String? {
        guard let first = versions.first, let last = versions.last else {
            return nil
        }
        if first == last {
            return Component(string: first).number
        }

        let head = Component(string: first)
        let tail = Component(string: last)

        guard head.name == tail.name else {
            return "\(first)–\(last)"
        }

        return "\(head.number)–\(tail.number)"
    }
}

private struct Component {
    let name: String
    let number: String

    init(string: String) {
        guard let space = string.lastIndex(of: " ") else {
            name = ""
            number = string
            return
        }

        name = String(string[..<space])
        number = String(string[string.index(after: space)...])
    }
}
