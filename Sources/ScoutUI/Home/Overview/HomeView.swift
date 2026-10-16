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

    @StateObject private var tint = Tint()

    init(backends: [Backend]) {
        let cache = RecordCache(location: RecordCacheLocation())

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

    var body: some View {
        Group {
            if let first = backends.first {
                HomeContent(first: first, others: Array(backends.dropFirst()))
            } else {
                EmptyHome()
            }
        }
        .background {
            Rectangle().fill(.background).ignoresSafeArea()
        }
        .onboardingSheet()
        .imageScale(.medium)
        .dynamicTypeSize(.large)
        .tint(tint.value)
        .environmentObject(tint)
    }
}

private struct HomeContent: View {
    let first: Backend
    let others: [Backend]

    @AppStorage("scout_active_backend") private var activeID = ""
    @State private var path: [HomeDestination] = []
    @State private var issue: ICloudIssue?

    private var backends: [Backend] {
        [first] + others
    }

    private var backend: Backend {
        backends.active(id: activeID) ?? first
    }

    private var active: Binding<String> {
        Binding {
            backend.id
        } set: {
            activeID = $0
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if case .account(.noAccount) = issue {
                    ErrorView(description: Backend.AccountError.noAccount.localizedDescription, retry: nil)
                } else {
                    HomeList(path: $path)
                }
            }
            .iCloudWarning(backend.verifyAccess, issue: $issue)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationTitle(en: "Home")
            .dismissable()
            .id(backend.id)
            .connectionToolbar(backends: backends, activeID: active)
        }
        .environment(\.database, backend.database)
    }
}

private struct EmptyHome: View {
    var body: some View {
        NavigationStack {
            ErrorView(description: "Pass at least one backend to inspect Scout data.", retry: nil)
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationTitle(en: "Home")
                .dismissable()
                .connectionToolbar(backends: [], activeID: .constant(""))
        }
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
