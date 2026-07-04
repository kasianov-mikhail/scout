//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    /// Presents the Scout home screen modally over this view.
    ///
    /// The screen is always shown as a full-screen cover, never pushed onto a navigation stack, so
    /// it keeps its own navigation and environment self-contained.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the home screen is shown.
    ///   - backends: The backends to inspect.
    /// - Returns: A view that presents the dashboard over this view while `isPresented` is `true`.
    ///
    public func scoutHome(isPresented: Binding<Bool>, backends: [Backend]) -> some View {
        fullScreenCover(isPresented: isPresented) {
            HomeView(backends: backends)
        }
    }
}

struct HomeView: View {
    let backends: [Backend]

    @AppStorage("scout_active_backend") private var activeID = ""
    @StateObject private var tint = Tint()

    init(backends: [Backend]) {
        self.backends = backends
    }

    private var backend: Backend? {
        backends.first(where: { $0.id == activeID }) ?? backends.first
    }

    private var activeIDBinding: Binding<String> {
        Binding(get: { backend?.id ?? "" }, set: { activeID = $0 })
    }

    var body: some View {
        NavigationStack {
            Group {
                if let backend {
                    HomeContent(
                        activity: ActivityProvider(),
                        sessionStat: StatProvider(eventName: "Session", periods: Period.summary),
                        crashStat: StatProvider(eventName: "Crash", periods: Period.summary),
                        releaseProvider: ReleaseHealthProvider()
                    )
                    .id(backend.id)
                    .iCloudWarning(backend.accountWarning)
                } else {
                    ErrorView(
                        description: Text(verbatim: "Pass at least one backend to inspect Scout data."),
                        retry: nil
                    )
                }
            }
            .navigationTitle(en: "Home")
            .dismissable()
            .connectionToolbar(backends: backends, activeID: activeIDBinding)
        }
        .tint(tint.value)
        .environment(\.database, backend?.database ?? DefaultDatabase())
        .environmentObject(tint)
    }
}

#Preview("No Backends") {
    HomeView(backends: [])
}
