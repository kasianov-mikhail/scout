//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension AlertSwipeRow {
    var displayOffset: CGFloat {
        if isActing {
            return offset
        }
        let proposed = min(swipeReveal, max(-swipeReveal, offset + drag))
        return onMute == nil ? min(0, proposed) : proposed
    }

    var dragGesture: some Gesture {
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

    func settle(to target: CGFloat) {
        let current = displayOffset
        drag = 0
        offset = current
        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
            offset = target
        }
    }

    func perform(direction: CGFloat, action: @escaping () -> Void) {
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
