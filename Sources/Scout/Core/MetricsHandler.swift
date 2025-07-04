//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Metrics

struct CKMetricsFactory: MetricsFactory {
    func makeCounter(label: String, dimensions: [(String, String)]) -> CounterHandler {
        fatalError()
    }

    func makeRecorder(label: String, dimensions: [(String, String)], aggregate: Bool)
        -> RecorderHandler
    {
        fatalError()
    }

    func makeTimer(label: String, dimensions: [(String, String)]) -> TimerHandler {
        fatalError()
    }

    func destroyCounter(_ handler: any CoreMetrics.CounterHandler) {

    }

    func destroyRecorder(_ handler: any CoreMetrics.RecorderHandler) {

    }

    func destroyTimer(_ handler: any CoreMetrics.TimerHandler) {

    }
}
