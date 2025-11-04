//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ProviderView<P: Provider, Content: View>: View {
    @ObservedObject var provider: P

    @ViewBuilder let content: (P.Output) -> Content

    var body: some View {
        switch provider.result {
        case nil:
            ProgressView().frame(maxHeight: .infinity).tint(nil)
        case .success(let data):
            content(data)
        case .failure(let error):
            ErrorView(error: error)
        }
    }
}
