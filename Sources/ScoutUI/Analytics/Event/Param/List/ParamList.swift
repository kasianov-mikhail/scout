//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ParamList: View {
    let items: [ParamProvider.Item]

    @StateObject private var model: ParamListModel

    init(items: [ParamProvider.Item]) {
        self.items = items
        self._model = StateObject(wrappedValue: ParamListModel(items: items))
    }

    private var text: String {
        items.map(\.description).joined(separator: "\n")
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    ParamRow(item: item)
                        .overlay(alignment: .bottom) {
                            if index < items.count - 1 {
                                Separator()
                            }
                        }
                }

                ParamRawView(raw: model.raw)
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
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

        NavigationLink {
            ParamView(item: item)
        } label: {
            ParamValueRow(
                value: value,
                label: item.key,
                labelStyle: .secondary,
                summaryStyle: value.isContainer ? .secondary : .primary
            )
            .frame(height: .rowRegular)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .lineLimit(1)
    }
}

#Preview {
    NavigationStack {
        ParamList(items: ParamProvider.Item.sampleMetrics)
    }
    .environmentObject(Tint())
}
