//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private struct PlaceholderKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isPlaceholder: Bool {
        get { self[PlaceholderKey.self] }
        set { self[PlaceholderKey.self] = newValue }
    }
}

extension View {
    func placeholder(_ isPlaceholder: Bool = true) -> some View {
        environment(\.isPlaceholder, isPlaceholder)
    }

    func placeholderHidden() -> some View {
        modifier(PlaceholderHidden())
    }
}

private struct PlaceholderHidden: ViewModifier {
    @Environment(\.isPlaceholder) private var isPlaceholder

    func body(content: Content) -> some View {
        content
            .opacity(isPlaceholder ? 0 : 1)
            .accessibilityHidden(isPlaceholder)
    }
}
