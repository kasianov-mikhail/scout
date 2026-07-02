//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct FunnelCohortEntry: Identifiable {
    let groupID: UUID
    let lastEvent: Event?

    var id: UUID { groupID }
}

@MainActor
class FunnelCohortProvider: ObservableObject {
    @Published var result: Result<[Event], Error>?

    func fetchIfNeeded(ids: [UUID], key: Funnel.CorrelationKey, in database: DatabaseReader) async {
        guard result == nil, ids.count > 0 else { return }

        do {
            let filter = RecordQuery.Filter(field: key.field, op: .in, value: .strings(ids.map(\.uuidString)))
            let query = RecordQuery(recordType: Event.self, filters: [filter])
            let events: [Event] = try await database.readAll(matching: query, fields: Event.desiredKeys)
            result = .success(events)
        } catch {
            result = .failure(error)
        }
    }

    func refresh(ids: [UUID], key: Funnel.CorrelationKey, in database: DatabaseReader) async {
        result = nil
        await fetchIfNeeded(ids: ids, key: key, in: database)
    }
}

extension Array where Element == Event {
    func cohortEntries(for groupIDs: [UUID], key: Funnel.CorrelationKey) -> [FunnelCohortEntry] {
        var groups: [UUID: [Event]] = [:]
        for event in self {
            guard let id = key.groupID(of: event) else { continue }
            groups[id, default: []].append(event)
        }

        return groupIDs.map { id in
            let last = groups[id]?.max { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
            return FunnelCohortEntry(groupID: id, lastEvent: last)
        }
    }
}
