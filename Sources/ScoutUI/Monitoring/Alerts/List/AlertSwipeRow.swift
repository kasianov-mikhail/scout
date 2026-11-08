//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private let swipeActionSize: CGFloat = 48
private let swipeReveal: CGFloat = 72

private enum SwipeSide: Equatable {
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

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var offset: CGFloat = 0
    @State private var drag: CGFloat = 0
    @State private var width: CGFloat = 0
    @State private var capsuleWidth = swipeActionSize
    @State private var capsuleOpacity = 1.0
    @State private var isActing = false

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

    private var actions: some View {
        ZStack {
            if displayOffset > 0, let onMute {
                actionButton(color: Color(.systemOrange), icon: "bell.slash", side: .trailing) {
                    perform(direction: 1, action: onMute)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if displayOffset < 0 {
                actionButton(color: Color(.systemRed), icon: "trash", side: .leading) {
                    perform(direction: -1, action: onDelete)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private func actionButton(color: Color, icon: String, side: SwipeSide, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Capsule()
                .fill(color)
                .frame(width: capsuleWidth, height: swipeActionSize)
                .overlay(alignment: side.alignment) {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(side.iconPadding, 14)
                }
        }
        .buttonStyle(.plain)
        .frame(maxHeight: .infinity)
        .contentShape(Rectangle())
        .padding(side.buttonPadding, 12)
        .opacity(capsuleOpacity)
        .accessibilityLabel(Text(verbatim: side.label))
    }

    private var displayOffset: CGFloat {
        if isActing {
            return offset
        }
        let proposed = min(swipeReveal, max(-swipeReveal, offset + drag))
        return onMute == nil ? min(0, proposed) : proposed
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard !isActing, abs(value.translation.width) > abs(value.translation.height) else {
                    return
                }
                drag = value.translation.width
            }
            .onEnded { value in
                guard !isActing else { return }

                let projected = displayOffset + value.predictedEndTranslation.width * 0.2
                let target: CGFloat =
                    if projected < -swipeReveal / 2 {
                        -swipeReveal
                    } else if projected > swipeReveal / 2 {
                        swipeReveal
                    } else {
                        0
                    }

                settle(to: target)
            }
    }

    private func settle(to target: CGFloat) {
        let current = displayOffset
        drag = 0
        offset = current
        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
            offset = target
        }
    }

    private func perform(direction: CGFloat, action: @escaping () -> Void) {
        guard !isActing else { return }

        guard !reduceMotion else {
            action()
            return
        }

        isActing = true
        let rowWidth = width > 0 ? width : 390

        withAnimation(.easeIn(duration: 0.18)) {
            offset = (rowWidth + swipeReveal) * direction
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(120))
            withAnimation(.easeInOut(duration: 0.2)) {
                capsuleWidth = max(swipeActionSize, rowWidth - 24)
            }

            try? await Task.sleep(for: .milliseconds(220))
            withAnimation(.easeOut(duration: 0.1)) {
                capsuleOpacity = 0
            }

            try? await Task.sleep(for: .milliseconds(100))
            offset = 0
            drag = 0
            capsuleWidth = swipeActionSize
            capsuleOpacity = 1
            isActing = false
            action()
        }
    }
}
