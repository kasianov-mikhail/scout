//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

typealias Tint = Box<Color?>

@MainActor class Box<T>: ObservableObject {
    @Published var value: T

    init(_ value: T) {
        self.value = value
    }
}

extension Box where T: ExpressibleByNilLiteral {
    convenience init() {
        self.init(nil)
    }
}

extension View {
    func navigationTint(_ color: Color?) -> some View {
        modifier(NavigationTint(color: color))
    }

    func resetsTint() -> some View {
        modifier(TintReset())
    }
}

private struct NavigationTint: ViewModifier {
    let color: Color?

    @EnvironmentObject private var tint: Tint

    func body(content: Content) -> some View {
        content
            .onAppear { tint.value = color }
            .onDisappear { tint.value = nil }
            .toolbarBackground(color?.opacity(0.12) ?? .clear, for: .navigationBar)
            .toolbarBackground(color == nil ? .automatic : .visible, for: .navigationBar)
    }
}

private struct TintReset: ViewModifier {
    @EnvironmentObject private var tint: Tint

    func body(content: Content) -> some View {
        content.onAppear { tint.value = nil }
    }
}
