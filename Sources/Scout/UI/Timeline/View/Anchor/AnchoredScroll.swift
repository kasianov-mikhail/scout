//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AnchoredScroll<ID: Hashable>: ViewModifier {
    let id: ID?

    /// The anchor's position in the list (rows above it).
    ///
    /// It only changes when pagination inserts rows above the anchor, which is
    /// exactly when the anchor needs re-centering to absorb the layout shift.
    ///
    let revision: Int

    @State private var anchorFrame: CGRect?

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let viewport = proxy.frame(in: .global)

            ScrollViewReader { proxy in
                ScrollView {
                    content
                }
                .overlay(alignment: .bottomTrailing) {
                    if let anchorFrame, let direction = RecenterDirection(frame: anchorFrame, viewport: viewport) {
                        RecenterButton(direction: direction) {
                            center(with: proxy)
                        }
                    }
                }
                .onAppear {
                    center(with: proxy)
                }
                .onChange(of: revision) { _ in
                    // Rows were prepended above the anchor. While the anchor is
                    // still on screen, re-center so the inserted chunk doesn't
                    // push it away; once the user has scrolled it off, leave
                    // the list alone.
                    if let anchorFrame, RecenterDirection(frame: anchorFrame, viewport: viewport) == nil {
                        center(with: proxy)
                    }
                }
                .onPreferenceChange(AnchorFrameKey.self) { frame in
                    guard let frame else { return }

                    let isFirst = anchorFrame == nil

                    anchorFrame = frame

                    // The first reported frame means the anchor row has just
                    // been laid out; the `onAppear` scroll only aimed at
                    // estimated lazy-row positions, so finish the initial
                    // centering with one precise pass.
                    if isFirst {
                        center(with: proxy)
                    }
                }
            }
            .environment(\.scrollViewport, viewport)
            // Footers must not self-load while the list still sits at its
            // initial offset — the top one is momentarily "visible" there and
            // would push the anchor away. The flag flips once the anchor lands
            // (or right away when there is no anchor to land).
            .environment(\.isScrollSettled, anchorFrame != nil || id == nil)
        }
    }

    private func center(with proxy: ScrollViewProxy) {
        if let id {
            proxy.scrollTo(id, anchor: .center)
        }
    }
}

extension View {
    func anchoredScroll<ID: Hashable>(id: ID?, revision: Int = 0) -> some View {
        modifier(AnchoredScroll(id: id, revision: revision))
    }
}

struct AnchorFrameKey: PreferenceKey {
    static let defaultValue: CGRect? = nil

    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = nextValue() ?? value
    }
}

extension EnvironmentValues {
    @Entry var scrollViewport: CGRect = .infinite

    /// Whether the anchored scroll has finished its initial positioning;
    /// pagination footers hold off self-loading until it has.
    @Entry var isScrollSettled = true
}

#Preview {
    let anchor = 38

    LazyVStack(spacing: 0) {
        ForEach(0..<40, id: \.self) { row in
            HStack {
                Text("Row \(row)").monospaced()
                Spacer()
                if row == anchor {
                    Text("anchor").foregroundStyle(.tint).font(.caption)
                }
            }
            .padding()
            .background(row == anchor ? Color.accentColor.opacity(0.12) : .clear)
        }
    }
    .anchoredScroll(id: anchor)
}
