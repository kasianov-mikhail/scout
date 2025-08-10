//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics

final class CKCounter: CounterHandler {
    func increment(by: Int64) {
        logMetrics(
            "name",
            telemetry: .counter,
            value: Double(by),
        )
    }

    func reset() {

    }
}

final class CKFloatingCounter: FloatingPointCounterHandler {
    func increment(by: Double) {
        logMetrics(
            "name",
            telemetry: .floatingCounter,
            value: by,
        )
    }

    func reset() {

    }
}

final class CKMeter: MeterHandler {
    func set(_ value: Int64) {

    }

    func set(_ value: Double) {

    }

    func increment(by: Double) {

    }

    func decrement(by: Double) {

    }
}

final class CKRecorder: RecorderHandler {
    func record(_ value: Int64) {

    }

    func record(_ value: Double) {

    }

}

final class CKTimer: TimerHandler {
    func recordNanoseconds(_ duration: Int64) {

    }
}
