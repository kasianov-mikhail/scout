//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ScrollStrip<Content: View>: View {
    var spacing: CGFloat = .space20

    private let content: Content
    private let fade: CGFloat = 56

    @State private var contentFrame = CGRect.zero
    @State private var viewport = CGFloat.zero

    private static var space: String { "ScrollStrip" }

    init(spacing: CGFloat = .space20, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                content
            }
            .padding(.horizontal, .gutter)
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollStripFrameKey.self,
                        value: proxy.frame(in: .named(Self.space))
                    )
                }
            }
        }
        .coordinateSpace(name: Self.space)
        .background {
            GeometryReader { proxy in
                Color.clear.preference(key: ScrollStripViewportKey.self, value: proxy.size.width)
            }
        }
        .mask { fadeMask }
        .padding(.top, .space8)
        .onPreferenceChange(ScrollStripFrameKey.self) { frame in
            contentFrame = frame
        }
        .onPreferenceChange(ScrollStripViewportKey.self) { width in
            viewport = width
        }
    }

    private var fadeMask: some View {
        HStack(spacing: 0) {
            LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                .frame(width: leadingFade)
            Rectangle()
            LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                .frame(width: trailingFade)
        }
    }

    private var leadingFade: CGFloat {
        min(fade, max(0, -contentFrame.minX))
    }

    private var trailingFade: CGFloat {
        min(fade, max(0, contentFrame.maxX - viewport))
    }
}

struct ScrollStripFrameKey: PreferenceKey {
    static let defaultValue = CGRect.zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ScrollStripViewportKey: PreferenceKey {
    static let defaultValue = CGFloat.zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    ScrollStrip {
        ForEach(0..<20, id: \.self) { index in
            Text(verbatim: "Item \(index)")
                .font(.scoutNumberL)
                .foregroundStyle(Color.textPrimary)
        }
    }
    .padding(.vertical)
}
