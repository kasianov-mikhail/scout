//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension EnvironmentValues {
    @Entry var database: DatabaseReader = DefaultDatabase()
}

struct DefaultDatabase: DatabaseReader {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: query.recordType.sampleRecords, cursor: nil)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        []
    }

    func metricSeries<T: MatrixValue & MetricSeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws -> [MetricSeries] {
        []
    }
}
