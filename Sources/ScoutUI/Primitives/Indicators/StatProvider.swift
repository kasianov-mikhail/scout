//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class StatProvider: ObservableObject, SeriesProvider {
    @Published var result: ProviderResult<[ChartPoint<Int>]>?

    enum Subject {
        case event(String)
        case sessions

        var name: String {
            switch self {
            case .event(let name):
                name
            case .sessions:
                SessionEntry.recordType
            }
        }
    }

    let subject: Subject

    init(_ result: ProviderResult<Output>? = nil, subject: Subject) {
        self.subject = subject
        self.result = result
    }

    func fetch(in database: SeriesReader) async throws -> [ChartPoint<Int>] {
        let range = Date().trailingYear

        let series =
            switch subject {
            case .event(let name):
                try await database.eventSeries(
                    matching: EventSeriesQuery(name: name, bucket: .hour, range: range)
                )
            case .sessions:
                try await database.lifecycleSeries(
                    matching: .sessions(bucket: .hour, range: range)
                )
            }

        return series.flatMap { $0.chartPoints() }
    }
}
