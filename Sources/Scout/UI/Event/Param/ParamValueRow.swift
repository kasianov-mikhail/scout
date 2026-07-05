//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ParamValueRow: View {
    let value: ParamValue
    let label: String
    let labelStyle: HierarchicalShapeStyle
    let summaryStyle: HierarchicalShapeStyle

    var body: some View {
        HStack(spacing: 13) {
            ParamIcon(value: value)

            Text(label)
                .foregroundStyle(labelStyle)

            Spacer()

            Text(value.summary)
                .monospaced()
                .font(.callout)
                .foregroundStyle(summaryStyle)
                .lineLimit(1)
        }
    }
}

extension ParamValueRow {
    init(node: ParamValue.Node) {
        self.init(
            value: node.value,
            label: node.label,
            labelStyle: node.value.isContainer ? .primary : .secondary,
            summaryStyle: node.value.isContainer ? .tertiary : .primary
        )
    }
}
