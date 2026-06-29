//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeContent: View {
    @StateObject private var releaseProvider: ReleaseHealthProvider
    @State private var showReleaseHealth = false

    init(releaseProvider: ReleaseHealthProvider = ReleaseHealthProvider()) {
        self._releaseProvider = StateObject(wrappedValue: releaseProvider)
    }

    var body: some View {
        List {
            HomeStatSection()
            HomeLogSection()
            HomeReleaseSection(provider: releaseProvider, showReleaseHealth: $showReleaseHealth)
        }
        .navigationDestination(isPresented: $showReleaseHealth) {
            ReleaseHealthView(provider: releaseProvider)
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
        HomeContent(releaseProvider: .fixture()).navigationTitle("Home")
    }
}
