//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoDatabase: DatabaseWriter, Sendable {
    let records: [Record]
    let samples: [DemoSample]
    let activityPoints: [ActivityPoint]
    let retentionCohorts: [RetentionCohort]

    init(corpus: DemoCorpus.Corpus) {
        records = corpus.records
        samples = corpus.samples
        activityPoints = corpus.activity
        retentionCohorts = corpus.retention
    }

    func write(record: Record) async throws {}
    func write(records: [Record]) async throws {}
}
