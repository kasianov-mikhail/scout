//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

extension ParamValue {
    /// A direct child of a container value, used to render drill-down lists.
    struct Node: Identifiable {
        /// The dictionary key or array index leading to the node.
        let label: String

        /// The value at this node.
        let value: ParamValue

        var id: String { label }
    }

    /// The direct children of a container: dictionary entries keyed by name,
    /// array elements keyed by index. Scalars have none.
    ///
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
