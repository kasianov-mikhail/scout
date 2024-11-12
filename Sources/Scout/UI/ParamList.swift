//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

struct ParamList: View {
    let items: [ParamProvider.Item]

    @EnvironmentObject var tint: Tint

    var body: some View {
        List {
            ForEach(items) { item in
                ParamRow(item: item)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Params")
        .onAppear {
            tint.value = nil
        }
    }
}

struct ParamRow: View {
    let item: ParamProvider.Item?

    var body: some View {
        ZStack {
            HStack {
                if let key = item?.key {
                    Text(key).foregroundStyle(.secondary)
                } else {
                    Redacted(length: 8).opacity(0.5)
                }

                Spacer()

                if let value = item?.value {
                    Text(value).monospaced().font(.system(size: 16))
                } else {
                    Redacted(length: 8).opacity(0.5)
                }
            }

            if let item {
                NavigationLink {
                    ParamView(item: item)
                } label: {
                    EmptyView()
                }
                .opacity(0)
            }
        }
        .lineLimit(1)
        .alignmentGuide(.listRowSeparatorTrailing) { dimension in
            dimension[.trailing]
        }
    }

    struct ParamView: View {
        let item: ParamProvider.Item

        @EnvironmentObject var tint: Tint

        var body: some View {
            ScrollView {
                Text(item.value)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .monospaced()
                    .navigationTitle(item.key)
                Spacer()
            }
            .onAppear {
                tint.value = nil
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        let items = [
            ParamProvider.Item(key: "key1", value: "value1"),
            ParamProvider.Item(key: "key2", value: "value2"),
            ParamProvider.Item(key: "key3", value: "value3")
        ]
        ParamList(items: items)
    }
    .environmentObject(Tint())
}
