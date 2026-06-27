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

    private var activeBackend: Backend {
        backends.first { $0.id == activeID } ?? backends.first!
    }

    public var body: some View {
        NavigationStack {
            HomeContent()
                .id(activeBackend.id)
                .navigationTitle(en: "Home")
                .backendWarnings(activeBackend)
                .dismissable()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        ConnectionMenu(
                            connections: backends.map(Connection.init),
                            activeID: Binding(get: { activeBackend.id }, set: { activeID = $0 })
                        )
                    }
                }
        }
        .onboardingSheet()
        .tint(tint.value)
        .environmentObject(tint)
        .environment(\.database, activeBackend.database)
    }
}

extension View {
    @ViewBuilder fileprivate func backendWarnings(_ backend: Backend?) -> some View {
        if let backend {
            accountWarning(backend).schemaWarning(backend)
        } else {
            self
        }
    }
}
