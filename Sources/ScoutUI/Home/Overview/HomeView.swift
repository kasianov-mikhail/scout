//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeView: View {
    @State private var backend: Backend?

    @State private var path = NavigationPath()

    @StateObject private var tint = Tint()

    init(backends: [Backend]) {
        let storage = RecordCacheStorage()
        let cache = RecordCache(storage: storage)

        let backend = backends.first(where: \.isCloudKit).map { backend in
            var backend = backend
            backend.database = CachingDatabase(
                base: backend.database,
                scope: backend.id,
                cache: cache,
                now: { Date() },
                types: [Event.recordType]
            )
            return backend
        }
        _backend = State(initialValue: backend)
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if let backend {
                    AccountGate(backend: backend) {
                        HomeOverview(path: $path).iCloudWarning(backend)
                    }
                } else {
                    ErrorView(description: "Pass a CloudKit backend to inspect Scout data.", retry: nil)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationTitle(en: "Home")
            .inlineNavigationTitle(divider: nil)
            .dismissable()
            .id(backend?.id)
        }
        .background {
            Rectangle().fill(.background).ignoresSafeArea()
        }
        .imageScale(.medium)
        .dynamicTypeSize(.large)
        .preferredColorScheme(.light)
        .font(.scoutBody)
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
    ///   - backends: The dashboard uses the first CloudKit backend in this array.
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

#Preview("No CloudKit Backend") {
    HomeView(backends: [])
}

extension Color {
    static let positive = textSuccess
    static let inactiveValue = textSecondary
    static let pending = textDisabled
}
