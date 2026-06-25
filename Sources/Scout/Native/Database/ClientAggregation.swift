//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKDatabase: ActivityReader, MetricSeriesReader {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        []
    }

    func metricSeries(category: String, values: String, in range: Range<Date>) async throws -> [MetricSeries] {
        []
    }
}
