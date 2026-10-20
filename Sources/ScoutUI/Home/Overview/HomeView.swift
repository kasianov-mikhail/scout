//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeView: View {
    @State private var backends: [Backend]

    @AppStorage("scout_active_backend") private var activeID = ""
    @State private var path: [HomeDestination] = []

    @StateObject private var tint = Tint()

    init(backends: [Backend]) {
        let storage = RecordCacheStorage()
        let cache = RecordCache(storage: storage)

        self._backends = State(
            initialValue: backends.map { backend in
                var backend = backend
                backend.database = CachingDatabase(
                    base: backend.database,
                    scope: backend.id,
                    cache: cache,
                    now: { Date() },
                    types: [EventEntry.recordType]
                )
                backend.cache = cache
                return backend
            }
        )
    }

    private var backend: Backend? {
        backends.active(id: activeID)
    }

    private var active: Binding<String> {
        Binding {
            backend?.id ?? ""
        } set: {
            activeID = $0
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if backend == nil {
                    ErrorView(description: "Pass at least one backend to inspect Scout data.", retry: nil)
                } else {
                    HomeList(path: $path)
                }
            }
            .iCloudWarning(backend)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationTitle(en: "Home")
            .dismissable()
            .id(backend?.id)
            .connectionToolbar(backends: backends, activeID: active)
        }
        .background {
            Rectangle().fill(.background).ignoresSafeArea()
        }
        .onboardingSheet()
        .imageScale(.medium)
        .dynamicTypeSize(.large)
        .environment(\.locale, Locale(identifier: "en_US"))
        .tint(tint.value)
        .environment(\.database, backend?.database ?? DefaultDatabase())
        .environmentObject(tint)
    }
}

extension View {
    /// Presents the Scout dashboard modally over this view.
    ///
    /// The dashboard is always shown as a full-screen cover on iOS (a sheet on macOS, which has no
    /// full-screen cover presentation), never pushed onto a navigation stack, so it keeps its own
    /// navigation and environment self-contained.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the dashboard is shown.
    ///   - backends: The backends to inspect.
    /// - Returns: A view that presents the dashboard over this view while `isPresented` is `true`.
    ///
    public func scoutHome(isPresented: Binding<Bool>, backends: [Backend]) -> some View {
        #if os(iOS)
            fullScreenCover(isPresented: isPresented) {
                HomeView(backends: backends)
            }
        #else
            sheet(isPresented: isPresented) {
                HomeView(backends: backends)
            }
        #endif
    }
}

#Preview("No Backends") {
    HomeView(backends: [])
}
