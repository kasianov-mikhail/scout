//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

public struct HomeView: View {
    let backends: [Backend]

    @AppStorage("scout_active_backend") private var activeID = ""
    @StateObject private var tint = Tint()

    public init(backends: [Backend]) {
        self.backends = backends
    }

    private var backend: Backend? {
        backends.first(where: { $0.id == activeID }) ?? backends.first
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let backend {
                    HomeContent()
                        .id(backend.id)
                        .accountWarning(backend)
                        .schemaWarning(backend)
                        .onboardingSheet()
                } else {
                    ErrorView(
                        description: Text(verbatim: "Pass at least one backend to inspect Scout data."),
                        retry: nil
                    )
                }
            }
            .navigationTitle(en: "Home")
            .dismissable()
            .toolbar {
                if let backend {
                    ToolbarItem(placement: .topBarTrailing) {
                        ConnectionMenu(
                            connections: backends.map(Connection.init),
                            activeID: Binding(get: { backend.id }, set: { activeID = $0 })
                        )
                    }
                }
            }
        }
        .tint(tint.value)
        .environment(\.database, backend?.database ?? DefaultDatabase())
        .environmentObject(tint)
    }
}

#Preview("No Backends") {
    HomeView(backends: [])
}
