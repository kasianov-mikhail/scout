//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// A position in an always-sorted list that `AnchoredScroll` tracks:
/// identified by `id`, ordered by `<`.
///
/// Because the list stays sorted, comparing two cursors tells which one sits
/// above the other, so direction needs no index lookup.
///
protocol ScrollCursor: Comparable, Hashable {
    associatedtype ID: Hashable
    var id: ID { get }
}

struct AnchoredScroll<Cursor: ScrollCursor>: ViewModifier {
    let cursor: Cursor?

    @State private var scroll: Cursor?

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            ScrollView {
                content
            }
            .scrollPosition(id: $scroll, anchor: .center)
            .overlay(alignment: .bottomTrailing) { recenterButton }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: scroll)
        } else {
            ScrollView { content }
        }
    }

    @ViewBuilder
    private var recenterButton: some View {
        if let pointsUp {
            Button {
                scroll = cursor
            } label: {
                let icon = Image(systemName: pointsUp ? "chevron.up" : "chevron.down")
                    .font(.title3)
                    .padding(12)
                #if compiler(>=6.2)
                    if #available(iOS 26.0, *) {
                        icon.glassEffect(.regular.interactive(), in: Circle())
                    } else {
                        icon.background(Circle().fill(.regularMaterial))
                    }
                #else
                    icon.background(Circle().fill(.regularMaterial))
                #endif
            }
            .padding(20)
            .transition(.scale.combined(with: .opacity))
        }
    }

    /// Whether the recenter chevron points up, or `nil` when there is no
    /// centered row to compare against — in which case the button stays hidden.
    ///
    private var pointsUp: Bool? {
        guard let cursor, let scroll, scroll != cursor else {
            return nil
        }
        return cursor < scroll
    }
}

extension View {
    /// Scrolls the content while tracking the centered row, showing a button
    /// that recenters on `cursor`.
    ///
    /// The content's row container must apply `scrollTargetLayoutIfAvailable()`
    /// so the centered row can be resolved.
    ///
    func anchoredScroll<Cursor: ScrollCursor>(cursor: Cursor?) -> some View {
        modifier(AnchoredScroll(cursor: cursor))
    }

    /// Marks this layout's subviews as scroll targets on iOS 17+, so a sibling
    /// `scrollPosition(id:)` can report the centered row; a no-op below iOS 17.
    ///
    @ViewBuilder
    func scrollTargetLayoutIfAvailable() -> some View {
        if #available(iOS 17.0, *) {
            scrollTargetLayout()
        } else {
            self
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var cursor = CursorItem(id: 5)

    let items = (0..<40).map(CursorItem.init)

    LazyVStack(spacing: 0) {
        ForEach(items, id: \.self) { item in
            HStack {
                Text("Row \(item.id)").monospaced()
                Spacer()
                if item == cursor {
                    Text("anchor").foregroundStyle(.tint).font(.caption)
                }
            }
            .padding()
            .background(item == cursor ? Color.accentColor.opacity(0.12) : .clear)
        }
    }
    .scrollTargetLayoutIfAvailable()
    .anchoredScroll(cursor: cursor)
    .task {
        await Task.yield()
        cursor = CursorItem(id: 30)
    }
}

#if DEBUG
    private struct CursorItem: ScrollCursor {
        let id: Int

        static func < (lhs: CursorItem, rhs: CursorItem) -> Bool {
            lhs.id < rhs.id
        }
    }
#endif
