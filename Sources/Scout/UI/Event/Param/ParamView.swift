//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ParamView: View {
    let item: ParamProvider.Item

    @EnvironmentObject var tint: Tint

    var body: some View {
        ScrollView {
            Text(item.value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .monospaced()
                .textSelection(.enabled)
                .navigationTitle(item.key)
            Spacer()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ShareLink(item: item.value)
                CopyButton(text: item.value)
                Spacer()
            }
        }
        .onAppear {
            tint.value = nil
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ParamView(
            item: ParamProvider.Item(
                key: "payload",
                value: """
                    {
                      "query": "8.8.8.8",
                      "country": "United States",
                      "isp": "Google LLC"
                    }
                    """
            )
        )
    }
    .environmentObject(Tint())
}
