//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ProviderView<P: Provider, Content: View>: View {
    @Environment(\.database) var database
    @ObservedObject var provider: P

    @ViewBuilder let content: (P.Output) -> Content

    var body: some View {
        Group {
            switch provider.result {
            case nil:
                RingIndicator().frame(maxHeight: .infinity)
            case .success(let data):
                content(data)
            case .failure(let error):
                ErrorView(description: Text(error.localizedDescription), retry: fetch)
            }
        }
        .periodRefresh(provider: provider)
    }

    private func fetch() async {
        await provider.fetchAgain(in: database)
    }
}
