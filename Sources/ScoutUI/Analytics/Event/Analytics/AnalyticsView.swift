//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AnalyticsView: View {
    @State private var filter = EventQuery()

    @StateObject var provider = EventProvider()
    @StateObject var search = EventProvider()

    var body: some View {
        EventList(provider: activeProvider)
            .eventFilter($filter, provider: provider, search: search)
            .navigationTitle(en: "Events")
            .resetsTint()
            .message($provider.message)
    }

    private var activeProvider: EventProvider {
        filter.text.isEmpty ? provider : search
    }
}

#Preview {
    let provider = EventProvider()
    provider.records = .samples

    return NavigationStack {
        AnalyticsView(provider: provider)
            .environmentObject(Tint())
    }
}
