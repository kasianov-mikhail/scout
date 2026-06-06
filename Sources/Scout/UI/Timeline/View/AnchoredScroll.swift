//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AnchoredScroll<ID: Hashable>: ViewModifier {
    let anchorID: ID?

    @State private var scrollID: ID?

    init(anchorID: ID?) {
        self.anchorID = anchorID
        self._scrollID = State(wrappedValue: anchorID)
    }

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            ScrollView {
                content.scrollTargetLayout()
            }
            .scrollPosition(id: $scrollID, anchor: .center)
            .overlay(alignment: .bottomTrailing) { recenterButton }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: scrollID)
        } else {
            ScrollView { content }
        }
    }

    @ViewBuilder
    private var recenterButton: some View {
        if let anchorID, scrollID != anchorID {
            Button {
                scrollID = anchorID
            } label: {
                let icon = Image(systemName: "scope")
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
}

extension View {
    func anchoredScroll<ID: Hashable>(anchorID: ID?) -> some View {
        modifier(AnchoredScroll(anchorID: anchorID))
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var anchorID = 5

    LazyVStack(spacing: 0) {
        ForEach(0..<40, id: \.self) { i in
            HStack {
                Text("Row \(i)").monospaced()
                Spacer()
                if i == anchorID {
                    Text("anchor").foregroundStyle(.tint).font(.caption)
                }
            }
            .padding()
            .background(i == anchorID ? Color.accentColor.opacity(0.12) : .clear)
        }
    }
    .anchoredScroll(anchorID: anchorID)
    .task {
        await Task.yield()
        anchorID = 30
    }
}
