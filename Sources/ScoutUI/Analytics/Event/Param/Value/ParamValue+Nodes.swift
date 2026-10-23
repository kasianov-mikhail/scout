//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

extension ParamValue {
    struct Node: Identifiable {
        let label: String

        let value: ParamValue

        var id: String { label }
    }

    var nodes: [Node] {
        switch self {
        case .dictionary(let entries):
            entries.map { Node(label: $0.key, value: $0.value) }
        case .array(let values):
            values.enumerated().map { Node(label: "\($0.offset)", value: $0.element) }
        case .string, .stringConvertible:
            []
        }
    }
}
