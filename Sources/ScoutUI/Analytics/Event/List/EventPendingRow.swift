//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct EventPendingRow: View {
    let events: [Event]
    let show: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded: Bool
    @State private var flash: Double = 0

    init(events: [Event], show: @escaping () -> Void) {
        self.events = events
        self.show = show
        _isExpanded = State(initialValue: !events.isEmpty)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: show) {
                HStack(spacing: 0) {
                    HStack(spacing: .space12) {
                        ForEach(summary.groups, id: \.level) { group in
                            HStack(spacing: .space4) {
                                EventLevelGlyph(level: group.level)

                                Text(verbatim: "\(group.count)")
                                    .font(.scoutValue)
                                    .foregroundStyle(Color.textPrimary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .fixedSize()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .fadingEdge(width: fadeWidth)

                    Text(verbatim: "Show \(summary.total) new")
                        .font(.scoutRowStrong)
                        .foregroundStyle(Color.textLink)
                        .lineLimit(1)
                        .layoutPriority(1)
                }
                .padding(.horizontal, .gutter)
                .frame(height: rowHeight)
                .contentShape(.rect)
            }
            .buttonStyle(StaticButtonStyle())

            Separator()
        }
        .frame(height: isExpanded ? rowHeight + .hairline : 0, alignment: .top)
        .background {
            Color.surfaceTrack
                .overlay(Color.fillAccent.opacity(flashInk * flash))
        }
        .clipped()
        .onChange(of: summary.isEmpty) { isEmpty in
            if isEmpty {
                isExpanded = false
            } else {
                withAnimation(reduceMotion ? nil : heightCurve) {
                    isExpanded = true
                }
            }
        }
        .task(id: summary.total) {
            guard summary.total > 0, !reduceMotion else {
                flash = 0
                return
            }
            flash = 1
            try? await Task.sleep(for: flashHold)
            guard !Task.isCancelled else {
                return
            }
            withAnimation(.easeOut(duration: flashFade)) {
                flash = 0
            }
        }
    }

    private var summary: EventPendingSummary {
        EventPendingSummary(events: events, limit: maxGroups)
    }
}

private struct StaticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

private let heightCurve = Animation.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.36)
private let rowHeight: CGFloat = 48
private let maxGroups = 4
private let fadeWidth: CGFloat = 28
private let flashInk = 0.1
private let flashHold = Duration.milliseconds(490)
private let flashFade = 0.91

private struct EventPendingRowDemo: View {
    @State private var events: [Event] = []

    var body: some View {
        VStack(spacing: 0) {
            EventPendingRow(events: events) {
                events = []
            }

            Button("Add 12 new") {
                events = Array(Event.samples.prefix(12))
            }
            .padding()

            Spacer()
        }
    }
}

#Preview("New Events") {
    EventPendingRowDemo()
}
