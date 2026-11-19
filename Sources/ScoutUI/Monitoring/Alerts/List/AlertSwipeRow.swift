//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

let swipeActionSize: CGFloat = 48
let swipeReveal: CGFloat = 72

enum SwipeSide: Equatable {
    case leading
    case trailing

    var alignment: Alignment {
        self == .leading ? .leading : .trailing
    }

    var iconPadding: Edge.Set {
        self == .leading ? .leading : .trailing
    }

    var buttonPadding: Edge.Set {
        self == .leading ? .trailing : .leading
    }

    var label: String {
        self == .leading ? "Delete" : "Mute"
    }
}

struct AlertSwipeRow<Content: View>: View {
    @ViewBuilder let content: () -> Content
    let onDelete: () -> Void
    let onMute: (() -> Void)?
    let onOpen: () -> Void

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @State var offset: CGFloat = 0
    @State var drag: CGFloat = 0
    @State var width: CGFloat = 0
    @State var capsuleWidth = swipeActionSize
    @State var capsuleOpacity = 1.0
    @State var isActing = false

    var body: some View {
        ZStack {
            actions

            content()
                .background()
                .contentShape(Rectangle())
                .offset(x: displayOffset)
                .simultaneousGesture(dragGesture)
                .onTapGesture {
                    guard !isActing else {
                        return
                    }
                    if offset == 0 {
                        onOpen()
                    } else {
                        settle(to: 0)
                    }
                }
                .accessibilityAction(named: Text(verbatim: "Delete")) {
                    perform(direction: -1, action: onDelete)
                }
                .accessibilityAction(named: Text(verbatim: "Mute")) {
                    guard let onMute else {
                        return
                    }
                    perform(direction: 1, action: onMute)
                }
        }
        .clipped()
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear { width = proxy.size.width }
                    .onChange(of: proxy.size.width) { width = $0 }
            }
        }
    }
}
