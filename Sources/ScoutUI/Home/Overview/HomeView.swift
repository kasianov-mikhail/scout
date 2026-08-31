//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeView: View {
    let backends: [Backend]

    @AppStorage("scout_active_backend") private var activeID = ""
    @State private var path: [HomeDestination] = []
    @StateObject private var tint = Tint()

    init(backends: [Backend]) {
        self.backends = backends
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
                if let backend {
                    HomeList(path: $path).iCloudWarning(backend.accountWarning)
                } else {
                    ErrorView(description: "Pass at least one backend to inspect Scout data.", retry: nil)
                }
            }
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
        .tint(tint.value)
        .environment(\.database, backend?.cachedDatabase ?? DefaultDatabase())
        .environmentObject(tint)
    }
}

extension View {
    /// Presents the Scout home screen modally over this view.
    ///
    /// The screen is always shown as a full-screen cover on iOS (a sheet on macOS, which has no
    /// full-screen cover presentation), never pushed onto a navigation stack, so it keeps its own
    /// navigation and environment self-contained.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the home screen is shown.
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
