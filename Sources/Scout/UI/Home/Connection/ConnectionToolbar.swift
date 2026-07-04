//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func connectionToolbar(backends: [Backend], activeID: Binding<String>) -> some View {
        modifier(ConnectionToolbar(backends: backends, activeID: activeID))
    }
}

private struct ConnectionToolbar: ViewModifier {
    let backends: [Backend]
    @Binding var activeID: String

    @State private var isSettingsPresented = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                if !backends.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        ConnectionMenu(
                            connections: backends.map(Connection.init),
                            activeID: $activeID,
                            onSettings: { isSettingsPresented = true }
                        )
                    }
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                NavigationStack {
                    SettingsOverviewView(backends: backends, activeID: $activeID)
                        .dismissable()
                }
            }
    }
}
