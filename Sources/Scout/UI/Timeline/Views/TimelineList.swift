//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

struct TimelineList: View {
    let rail: DeviceRail
    var eventName: String? = nil
    @Binding var scope: TimelineScope
    var onLoadMore: (() async -> Void)?
    var isPaging = false

    let timeline = Date()

    @State private var showLegend = false
    @State private var expandedKind: RailKind?

    private var rows: [TimelineItem] {
        var result: [TimelineItem] = []

        for install in rail.installs {
            for launch in install.launches {
                for session in launch.sessions {
                    for event in session.events.sorted(byDate: \.date) {
                        guard let date = event.date else { continue }
                        result.append(
                            TimelineItem(
                                id: event.id,
                                name: event.name,
                                date: date,
                                active: [.install, .launch, .session],
                                isCrash: false,
                                installID: install.install.installID,
                                launchID: launch.launch.launchID,
                                sessionID: session.session.sessionID
                            )
                        )
                    }
                }
            }
        }

        if scope == .event, let eventName {
            return result.filter { $0.name == eventName }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            if showLegend {
                TimelineLegend(kinds: RailKind.allCases, expanded: $expandedKind)
            }

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                        TimelineRow(
                            color: row.isCrash ? .red : .primary,
                            name: row.name,
                            date: row.date,
                            timeline: timeline
                        ) {
                            ForEach(RailKind.allCases, id: \.self) { kind in
                                let prev = rows[safe: index - 1]
                                let next = rows[safe: index + 1]

                                TimelineSegment(
                                    color: kind.color,
                                    isActive: row.active.contains(kind),
                                    prevActive: connected(prev, row, on: kind),
                                    nextActive: connected(next, row, on: kind)
                                )
                            }
                        }

                        if let next = rows[safe: index + 1], sameSection(row, next) {
                            Divider().padding(.leading, CGFloat(RailKind.allCases.count) * 16 + 8)
                        }
                    }

                    if isPaging {
                        ProgressView().frame(height: 72).frame(maxWidth: .infinity)
                    } else if let onLoadMore {
                        PaginationFooter {
                            await onLoadMore()
                        }
                    }
                }
                .padding()
            }
        }
        .toolbar {
            if eventName != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        scope.toggle()
                    } label: {
                        Image(systemName: scope.symbol)
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showLegend.toggle()
                        if !showLegend { expandedKind = nil }
                    }
                } label: {
                    Image(systemName: showLegend ? "info.circle.fill" : "info.circle")
                }
            }
        }
    }
}

#Preview("All") {
    NavigationView { TimelineList(rail: .sample, scope: .constant(.all)) }
}

#Preview("Event filter") {
    NavigationView {
        TimelineList(rail: .sample, eventName: "ip_lookup", scope: .constant(.event))
    }
}
