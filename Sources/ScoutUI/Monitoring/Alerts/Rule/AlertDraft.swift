//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct AlertDraft: Equatable {
    var watch: Watch
    var eventName: String
    var sensitivity: Sensitivity
    var stabilityThreshold: Double
    var countThreshold: Double
    var notifies: Bool

    var spikeReference: SpikeReference
    var countComparison: AlertCondition.Comparison
}

extension AlertDraft {
    enum Watch: CaseIterable, Hashable {
        case crashFreeDrop
        case eventSpike
        case eventSilence
        case eventCount
    }

    enum Sensitivity: CaseIterable, Hashable {
        case low
        case normal
        case high
    }

    enum SpikeReference: Hashable {
        case median
        case baseline
    }
}
