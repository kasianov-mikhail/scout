//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class AlertBacktestProvider: ObservableObject, SeriesProvider {
    @Published var result: ProviderResult<AlertWeek>?

    var metric: AlertMetric

    var week: AlertWeek? {
        guard let result else {
            return nil
        }
        guard case .success(let week) = result else {
            return nil
        }
        return week
    }

    init(metric: AlertMetric) {
        self.metric = metric
    }

    func fetch(in database: SeriesReader) async throws -> AlertWeek {
        let today = Date().startOfDay
        let start = today.addingDay(-9)
        let values = try await metric.values(in: database, range: start..<today)

        return AlertWeek(start: start, values: values, end: today)
    }
}
