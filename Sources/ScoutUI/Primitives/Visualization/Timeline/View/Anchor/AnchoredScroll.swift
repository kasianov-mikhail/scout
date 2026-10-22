//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private struct AnchoredScroll<ID: Hashable>: ViewModifier {
    let id: ID?

    let revision: Int

    @State private var anchorFrame: CGRect?

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let viewport = proxy.frame(in: .global)

            ScrollViewReader { proxy in
                ScrollView {
                    content
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        if let anchorFrame, let direction = RecenterDirection(frame: anchorFrame, viewport: viewport) {
                            Button {
                                withAnimation {
                                    center(with: proxy)
                                }
                            } label: {
                                Image(systemName: direction.symbol)
                            }
                        }
                    }
                }
                .onAppear {
                    center(with: proxy)
                }
                .onChange(of: revision) { _ in
                    if let anchorFrame, RecenterDirection(frame: anchorFrame, viewport: viewport) == nil {
                        center(with: proxy)
                    }
                }
                .onPreferenceChange(AnchorFrameKey.self) { frame in
                    guard let frame else { return }

                    let isFirst = anchorFrame == nil

                    anchorFrame = frame

                    if isFirst {
                        center(with: proxy)
                    }
                }
            }
            .environment(\.scrollViewport, viewport)
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
    func anchoredScroll(id: (some Hashable)?, revision: Int = 0) -> some View {
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

    @Entry var isScrollSettled = true
}

#Preview {
    let anchor = 38

    NavigationStack {
        LazyVStack(spacing: 0) {
            ForEach(0..<40, id: \.self) { row in
                HStack {
                    Text(verbatim: "Row \(row)").monospaced()
                    Spacer()
                    if row == anchor {
                        Text(verbatim: "anchor").foregroundStyle(.tint).font(.caption)
                    }
                }
                .padding()
                .background {
                    if row == anchor {
                        Color.accentColor.opacity(0.12)
                        GeometryReader { geo in
                            Color.clear.preference(key: AnchorFrameKey.self, value: geo.frame(in: .global))
                        }
                    }
                }
            }
        }
        .anchoredScroll(id: anchor)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }

                Button {
                } label: {
                    Image(systemName: "doc.on.doc")
                }

                Spacer()
            }
        }
    }
}
