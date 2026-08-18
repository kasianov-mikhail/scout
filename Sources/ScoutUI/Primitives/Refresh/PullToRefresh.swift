//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    @ViewBuilder
    func pullToRefresh(action: @escaping () async -> Void) -> some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            modifier(PullToRefreshModifier(action: action))
        } else {
            refreshable { await action() }
        }
    }
}

@available(iOS 18.0, macOS 15.0, *)
private struct PullToRefreshModifier: ViewModifier {
    static let ringSize: CGFloat = 22
    static let settleFallback: Duration = .seconds(1)

    let action: () async -> Void

    @State private var state = PullState()
    @State private var generation = 0
    @State private var isDragging = false

    func body(content: Content) -> some View {
        content
            .onScrollPhaseChange { _, phase in
                isDragging = phase == .interacting || phase == .tracking
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                state.inset - geometry.contentOffset.y - geometry.contentInsets.top
            } action: { _, pull in
                var next = state

                if next.update(pull: pull, dragging: isDragging) {
                    refresh()
                }
                if next != state {
                    state = next
                }
            }
            .topContentMargin(state.inset)
            .overlay(alignment: .top) {
                ring.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).clipped()
            }
            .accessibilityAction(named: Text(verbatim: "Refresh")) {
                if state.trigger() {
                    refresh()
                }
            }
            .hapticFeedback(.impact, trigger: generation)
    }

    @ViewBuilder private var ring: some View {
        if state.isVisible {
            RingIndicator(size: Self.ringSize, progress: state.progress)
                .scaleEffect(state.ringScale)
                .offset(y: state.ringOffset(size: Self.ringSize))
        }
    }

    // Detached from the view lifecycle on purpose: `.task(id:)` would restart
    // the action on every reappearance and cancel it mid-flight on disappear.
    private func refresh() {
        generation += 1

        Task {
            await action()
            withAnimation {
                state.finish()
            } completion: {
                state.settle()
            }
            try? await Task.sleep(for: Self.settleFallback)
            state.settle()
        }
    }
}

#Preview("Scroll") {
    NavigationStack {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<40, id: \.self) { row in
                    Text(verbatim: "Row \(row)")
                        .monospaced()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
        }
        .pullToRefresh {
            try? await Task.sleep(for: .seconds(2))
        }
        .navigationTitle(en: "Pull to refresh")
    }
}

#Preview("List") {
    NavigationStack {
        InsetList {
            Header(title: "Rows")

            ForEach(0..<40, id: \.self) { row in
                Text(verbatim: "Row \(row)").monospaced()
            }
        }
        .pullToRefresh {
            try? await Task.sleep(for: .seconds(2))
        }
        .navigationTitle(en: "Pull to refresh")
    }
}
