//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RefreshableList<Content: View>: View {
    private enum Phase {
        case idle
        case refreshing
        case finishing

        var isRefreshing: Bool {
            self == .refreshing
        }

        var isSpinning: Bool {
            self != .idle
        }
    }

    private let indicatorSize: CGFloat = 28
    private let retractDuration = 0.3

    private let action: () async -> Void
    private let content: Content

    @State private var tracker = PullTracker(threshold: 80, releaseVelocity: 150)
    @State private var gap: CGFloat = 0
    @State private var phase: Phase = .idle

    init(action: @escaping () async -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        GeometryReader { outer in
            let viewportTop = outer.frame(in: .global).minY
            let pull = phase.isSpinning ? 0 : max(tracker.offset, 0)
            let arcProgress = pull / tracker.threshold
            let topInset: CGFloat = phase.isRefreshing ? tracker.threshold : 0

            List {
                Section {
                    content
                } header: {
                    // The header rides the top of the content to measure
                    // the pull.
                    Color.clear
                        .frame(height: 1)
                        .listRowInsets(EdgeInsets())
                        .background {
                            GeometryReader { geo in
                                let pulled = geo.frame(in: .global).minY - viewportTop

                                Color.clear
                                    .onAppear { handle(offset: pulled) }
                                    .onChange(of: pulled) { handle(offset: $0) }
                            }
                        }
                }
            }
            .alwaysBounceVertically()
            .listStyle(.plain)
            .environment(\.defaultMinListHeaderHeight, 0)
            .padding(.top, topInset)
            .overlay(alignment: .top) {
                let progress = min(arcProgress, 1)
                let revealed = max(gap, 0)

                RingIndicator(size: indicatorSize, progress: phase.isSpinning ? nil : arcProgress)
                    .scaleEffect(phase.isRefreshing ? 1 : 0.4 + 0.6 * progress)
                    .opacity(phase.isRefreshing ? 1 : progress)
                    .offset(y: revealed / 2 - indicatorSize / 2)
            }
        }
    }

    private func handle(offset value: CGFloat) {
        gap = value

        // The top padding shifts the whole list while refreshing, so samples
        // taken mid-cycle would read the inset as a new pull and re-fire;
        // the tracker only listens while idle.
        guard phase == .idle, tracker.update(offset: value, at: Date.timeIntervalSinceReferenceDate) else {
            return
        }

        // The inset is applied without animation: it lands in the same layout
        // pass that clamps the interrupted bounce, so the content is caught
        // near the release point instead of dipping to zero first.
        phase = .refreshing

        Task {
            await action()

            withAnimation(.easeInOut(duration: retractDuration)) {
                phase = .finishing
            }

            try? await Task.sleep(for: .seconds(retractDuration))
            phase = .idle
        }
    }
}

extension View {
    @ViewBuilder
    fileprivate func alwaysBounceVertically() -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            self.scrollBounceBehavior(.always)
        } else {
            self
        }
    }
}

struct PullTracker {
    let threshold: CGFloat
    let releaseVelocity: CGFloat

    private(set) var offset: CGFloat = 0
    private var baseline: CGFloat?
    private var timestamp: TimeInterval?
    private var armed = false

    init(threshold: CGFloat, releaseVelocity: CGFloat) {
        self.threshold = threshold
        self.releaseVelocity = releaseVelocity
    }

    mutating func update(offset raw: CGFloat, at time: TimeInterval) -> Bool {
        let base = baseline ?? raw
        baseline = base

        let value = raw - base
        let elapsed = time - (timestamp ?? time)
        let velocity = elapsed > 0 ? (offset - value) / elapsed : 0

        timestamp = time
        offset = value

        // A released pull snaps back ballistically while a finger walking
        // the list back moves slowly, so the speed at which the threshold
        // is crossed tells a release from a cancelled pull.
        if armed, value < threshold {
            armed = false
            return velocity > releaseVelocity
        }

        if value >= threshold {
            armed = true
        }

        return false
    }
}

#Preview {
    RefreshableList {
        try? await Task.sleep(for: .seconds(1.5))
    } content: {
        ForEach(0..<40, id: \.self) { index in
            Text(verbatim: "Item \(index)")
        }
    }
}
