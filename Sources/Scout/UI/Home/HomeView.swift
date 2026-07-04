//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

// The latest scout-db schema bootstrap failure, shown on the home screen.
@MainActor let schemaBootstrapMessage = Box<String?>(nil)

public struct HomeView: View {
    let backends: [Backend]

    @AppStorage("scout_active_backend") private var activeID = ""
    @StateObject private var tint = Tint()
    @ObservedObject private var schema = schemaBootstrapMessage
    @State private var isSettingsPresented = false

    public init(backends: [Backend]) {
        self.backends = backends
    }

    private var backend: Backend? {
        backends.first(where: { $0.id == activeID }) ?? backends.first
    }

    private var activeIDBinding: Binding<String> {
        Binding(get: { backend?.id ?? "" }, set: { activeID = $0 })
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let backend {
                    if let message = schema.value {
                        ErrorView(description: Text(verbatim: message), retry: nil)
                    } else {
                        HomeContent()
                            .id(backend.id)
                            .accountWarning(backend)
                            .onboardingSheet()
                    }
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
                if backend != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        ConnectionMenu(
                            connections: backends.map(Connection.init),
                            activeID: activeIDBinding,
                            onSettings: { isSettingsPresented = true }
                        )
                    }
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                NavigationStack {
                    SettingsOverviewView(backends: backends, activeID: activeIDBinding)
                        .dismissable()
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
