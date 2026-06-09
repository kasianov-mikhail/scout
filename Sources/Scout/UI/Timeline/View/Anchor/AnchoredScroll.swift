//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AnchoredScroll<ID: Hashable>: ViewModifier {
    let id: ID?

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
            }
            .environment(\.scrollViewport, viewport)
            .onPreferenceChange(AnchorFrameKey.self) { frame in
                if let frame {
                    anchorFrame = frame
                }
            }
        }
    }

    private func center(with proxy: ScrollViewProxy) {
        if let id {
            proxy.scrollTo(id, anchor: .center)
        }
    }
}

extension View {
    func anchoredScroll<ID: Hashable>(id: ID?) -> some View {
        modifier(AnchoredScroll(id: id))
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
