//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeContent: View {
    var body: some View {
        List {
            HomeStatSection()
            HomeLogSection()
            HomeReleaseSection()
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background {
            Rectangle()
                .fill(.background)
                .ignoresSafeArea()
        }
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        HomeContent().navigationTitle("Home")
    }
}
