//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ParamList: View {
    let items: [ParamProvider.Item]

    @EnvironmentObject var tint: Tint

    /// All parameters as `key: value` lines, used for sharing and copying.
    private var text: String {
        items.map(\.description).joined(separator: "\n")
    }

    var body: some View {
        List {
            ForEach(items) { item in
                ParamRow(item: item)
            }
        }
        .listStyle(.plain)
        .navigationTitle(en: "Params")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ShareLink(item: text)
                CopyButton(text: text)
                Spacer()
            }
        }
        .onAppear {
            tint.value = nil
        }
    }
}

struct ParamRow: View {
    let item: ParamProvider.Item?

    var body: some View {
        ZStack {
            if let item {
                let value = ParamValue(parsing: item.value)

                ParamValueRow(
                    value: value,
                    label: item.key,
                    labelStyle: .secondary,
                    summaryStyle: value.isContainer ? .secondary : .primary
                )

                NavigationLink {
                    ParamView(item: item)
                } label: {
                    EmptyView()
                }
                .opacity(0)
            } else {
                HStack(spacing: 13) {
                    Redacted(length: 2)
                        .frame(width: 24)
                        .opacity(0.5)

                    Redacted(length: 8).opacity(0.5)

                    Spacer()

                    Redacted(length: 8).opacity(0.5)
                }
            }
        }
        .lineLimit(1)
        .alignmentGuide(.listRowSeparatorTrailing) { dimension in
            dimension[.trailing]
        }
    }
}

#Preview {
    NavigationStack {
        ParamList(items: ParamProvider.Item.sampleMetrics)
    }
    .environmentObject(Tint())
}
