//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    /// Records this view as a screen while it is visible.
    ///
    /// The view records into the runtime from the environment, so set it once near the
    /// root of the app. Without a runtime, the modifier records nothing.
    ///
    /// ```swift
    /// ContentView()
    ///     .environment(\.scoutRuntime, scout)
    ///
    /// FeedView()
    ///     .scoutScreen(name: "Feed")
    /// ```
    ///
    /// See ``Runtime/openScreen(name:)`` for how Scout picks the current screen.
    ///
    /// - Parameter name: The screen name that groups its views in the dashboard.
    /// - Returns: The view that records itself as a screen.
    ///
    public func scoutScreen(name: String) -> some View {
        modifier(ScreenTracking(name: name))
    }
}

extension EnvironmentValues {
    /// The runtime that ``SwiftUI/View/scoutScreen(name:)`` records into.
    public var scoutRuntime: Runtime? {
        get { self[RuntimeKey.self] }
        set { self[RuntimeKey.self] = newValue }
    }
}

private struct RuntimeKey: EnvironmentKey {
    static let defaultValue: Runtime? = nil
}

private struct ScreenTracking: ViewModifier {
    let name: String

    @Environment(\.scoutRuntime) private var runtime
    @State private var visit: ScreenVisit?

    func body(content: Content) -> some View {
        content
            .onAppear {
                visit = runtime?.openScreen(name: name)
            }
            .onDisappear {
                visit?.end()
                visit = nil
            }
    }
}
