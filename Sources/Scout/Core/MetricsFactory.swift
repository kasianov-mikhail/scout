//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Metrics

struct CKMetricsFactory: MetricsFactory {
    func makeCounter(label: String, dimensions: [(String, String)]) -> CounterHandler {
        return CKCounter()
    }

    func makeFloatingPointCounter(label: String, dimensions: [(String, String)])
        -> FloatingPointCounterHandler
    {
        return CKFloatingCounter()
    }

    func makeMeter(label: String, dimensions: [(String, String)]) -> MeterHandler {
        return CKMeter()
    }

    func makeRecorder(label: String, dimensions: [(String, String)], aggregate: Bool)
        -> RecorderHandler
    {
        return CKRecorder()
    }

    func makeTimer(label: String, dimensions: [(String, String)]) -> TimerHandler {
        return CKTimer()
    }

    func destroyCounter(_ handler: CounterHandler) {

    }

    func destroyMeter(_ handler: MeterHandler) {

    }

    func destroyRecorder(_ handler: RecorderHandler) {

    }

    func destroyTimer(_ handler: TimerHandler) {

    }
}

final class CKCounter: CounterHandler {
    func increment(by: Int64) {

    }

    func reset() {

    }
}

final class CKFloatingCounter: FloatingPointCounterHandler {
    func increment(by: Double) {

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
