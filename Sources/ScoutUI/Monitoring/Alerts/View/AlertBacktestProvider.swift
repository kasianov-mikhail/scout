//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class AlertBacktestProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<AlertBacktest>?

    var metric: AlertMetric

    init(metric: AlertMetric) {
        self.metric = metric
    }

    func fetch(in database: DatabaseReader) async throws -> AlertBacktest {
        let horizon = Date().startOfHour
        let values = try await metric.values(in: database, range: horizon.addingDay(-9)..<horizon)
        return AlertBacktest(values: values)
    }
}
