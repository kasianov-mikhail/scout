//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@MainActor
class FunnelProvider: ObservableObject {
    @Published var result: Result<[Event], Error>?

    private struct Request: Hashable {
        let names: [String]
        let range: Range<Date>
    }

    private var request: Request?

    func fetchIfNeeded(names: [String], range: Range<Date>, in database: DatabaseReader) async {
        let request = Request(names: names, range: range)
        guard request != self.request else { return }

        self.request = request
        result = nil

        do {
            let filters = [RecordQuery.Filter(field: "name", op: .in, value: .strings(names))] + range.dateFilters
            let query = RecordQuery(recordType: Event.self, filters: filters)
            let events: [Event] = try await database.readAll(matching: query, fields: Event.desiredKeys)
            result = .success(events)
        } catch {
            result = .failure(error)
            self.request = nil
        }
    }

    func refresh(names: [String], range: Range<Date>, in database: DatabaseReader) async {
        request = nil
        await fetchIfNeeded(names: names, range: range, in: database)
    }
}

extension FunnelProvider {
    static func fixture() -> FunnelProvider {
        let provider = FunnelProvider()
        provider.result = .success(.funnelSample)
        provider.request = Request(names: FunnelStep.samples.map(\.name), range: Period.month.initialRange)
        return provider
    }
}

extension Array where Element == Event {
    static var funnelSample: [Event] {
        let names = FunnelStep.samples.map(\.name)
        let counts = [21, 13, 8, 5, 3]
        let start = Period.month.initialRange.lowerBound

        var events: [Event] = []
        for session in 0..<counts[0] {
            let id = UUID()
            for (index, name) in names.enumerated() where counts[index] > session {
                events.append(
                    Event.sample(
                        name,
                        at: start.addingTimeInterval(Double(session * 3600 + index * 60)),
                        sessionID: id
                    )
                )
            }
        }
        return events
    }
}
