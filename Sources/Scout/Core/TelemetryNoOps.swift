//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Metrics

final class NoOpMeter: MeterHandler {
    func set(_ value: Int64) {

    }

    func set(_ value: Double) {

    }

    func increment(by: Double) {

    }

    func decrement(by: Double) {

    }
}

final class NoOpRecorder: RecorderHandler {
    func record(_ value: Int64) {

    }

    func record(_ value: Double) {

    }
}
