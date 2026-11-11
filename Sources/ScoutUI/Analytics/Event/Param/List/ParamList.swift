//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ParamList: View {
    let items: [ParamProvider.Item]

    private var text: String {
        items.map(\.description).joined(separator: "\n")
    }

    var body: some View {
        InsetList {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                ParamRow(item: item)
                    .overlay(alignment: .bottom) {
                        if index < items.count - 1 {
                            Separator()
                        }
                    }
            }
        }
        .navigationTitle(en: "Params")
        .largeNavigationTitle()
        .exportToolbar(text: text)
        .resetsTint()
    }
}

struct ParamRow: View {
    let item: ParamProvider.Item

    var body: some View {
        let value = ParamValue(parsing: item.value)

        Row {
            ParamValueRow(
                value: value,
                label: item.key,
                labelStyle: .secondary,
                summaryStyle: value.isContainer ? .secondary : .primary
            )
        } destination: {
            ParamView(item: item)
        }
        .lineLimit(1)
    }
}

#Preview {
    NavigationStack {
        ParamList(items: ParamProvider.Item.sampleMetrics)
    }
    .environmentObject(Tint())
}
