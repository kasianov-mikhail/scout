//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

struct Timeline: View {
    let device: DeviceRail = .sample
    let timeline = Date()

    @State private var showLegend = false
    @State private var expandedKind: RailKind?

    private var rows: [Row] {
        var result: [Row] = []

        for install in device.installs {
            for launch in install.launches {
                for session in launch.sessions {
                    let events = session.events.map { Item.event($0) }
                    let crashes = session.crashes.map { Item.crash($0) }
                    let merged = (events + crashes).sorted(byDate: \.date)

                    for item in merged {
                        guard let date = item.date else { continue }
                        let active: Set<RailKind> =
                            item.isCrash
                            ? [.install]
                            : [.install, .launch, .session]
                        result.append(Row(id: item.id, name: item.name, date: date, active: active, isCrash: item.isCrash))
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
                                    prevActive: prev?.active.contains(kind) ?? false,
                                    nextActive: next?.active.contains(kind) ?? false
                                )
                            }
                        }
                        Divider().padding(.leading, CGFloat(RailKind.allCases.count) * 16 + 8)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Multi-Rail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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

extension Timeline {
    fileprivate struct Row: Identifiable {
        let id: CKRecord.ID
        let name: String
        let date: Date
        let active: Set<RailKind>
        let isCrash: Bool
    }

    fileprivate enum Item {
        case event(Event)
        case crash(Crash)

        var id: CKRecord.ID {
            switch self {
            case .event(let x): x.id
            case .crash(let x): x.id
            }
        }

        var name: String {
            switch self {
            case .event(let x): x.name
            case .crash(let x): x.name
            }
        }

        var date: Date? {
            switch self {
            case .event(let x): x.date
            case .crash(let x): x.date
            }
        }

        var isCrash: Bool {
            if case .crash = self { true } else { false }
        }
    }
}

#Preview {
    NavigationView { Timeline() }
}
