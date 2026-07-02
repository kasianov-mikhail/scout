//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Funnel: Hashable {
    static let stepLimit = 2...6

    enum CorrelationKey: String, CaseIterable, Identifiable {
        case session
        case install

        var id: Self { self }

        var title: String {
            switch self {
            case .session: "Session"
            case .install: "Install"
            }
        }

        var field: String {
            switch self {
            case .session: "session_id"
            case .install: "install_id"
            }
        }

        func groupID(of event: Event) -> UUID? {
            switch self {
            case .session: event.sessionID
            case .install: event.installID
            }
        }
    }

    var stepNames: [String] = []
    var key = CorrelationKey.session

    var isRunnable: Bool {
        Funnel.stepLimit.contains(stepNames.count)
    }

    func steps(from events: [Event]) -> [FunnelStep] {
        let depths = Array(depths(from: events).values)
        return stepNames.enumerated().map { index, name in
            FunnelStep(name: name, count: depths.filter { $0 > index }.count)
        }
    }

    func droppedIDs(before index: Int, from events: [Event]) -> [UUID] {
        guard index > 0 else { return [] }
        return depths(from: events)
            .filter { $0.value == index }
            .map(\.key)
            .sorted { $0.uuidString < $1.uuidString }
    }

    private func depths(from events: [Event]) -> [UUID: Int] {
        var groups: [UUID: [Event]] = [:]
        for event in events {
            guard let id = key.groupID(of: event) else { continue }
            groups[id, default: []].append(event)
        }
        return groups.mapValues(depth)
    }

    private func depth(of events: [Event]) -> Int {
        var depth = 0
        let sorted = events.sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
        for event in sorted where depth < stepNames.count && event.name == stepNames[depth] {
            depth += 1
        }
        return depth
    }
}
