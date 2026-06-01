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
    @Binding var showLegend: Bool
    @Binding var expandedKind: RailKind?
    var onLoadMore: (() async -> Void)?
    var isPaging = false

    let timeline = Date()

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
    }
}

#Preview {
    NavigationView {
        TimelineList(rail: .sample, showLegend: .constant(false), expandedKind: .constant(nil))
    }
}
