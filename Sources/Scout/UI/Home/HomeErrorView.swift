//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeErrorView: View {
    @Environment(\.database) var database

    let providers: [any Provider]
    let error: Error

    init?(providers: [any Provider]) {
        guard let error = providers.compactMap(\.error).first else {
            return nil
        }
        self.providers = providers
        self.error = error
    }

    var body: some View {
        ErrorView(description: error.localizedDescription) {
            for provider in providers {
                Task {
                    await provider.fetchIfFailed(in: database)
                }
            }
        }
    }
}
