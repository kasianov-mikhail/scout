//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension AlertDraft.Sensitivity {
    var title: String {
        switch self {
        case .low:
            "Low"
        case .normal:
            "Normal"
        case .high:
            "High"
        }
    }

    var holdBuckets: Int {
        switch self {
        case .low:
            3
        case .normal:
            2
        case .high:
            1
        }
    }

    var spikeFactor: Double {
        switch self {
        case .low:
            5
        case .normal:
            3
        case .high:
            2
        }
    }

    var silenceFactor: Double {
        switch self {
        case .low:
            0.25
        case .normal:
            0.5
        case .high:
            0.75
        }
    }
}

extension AlertDraft.Sensitivity {
    init(holdBuckets: Int) {
        switch holdBuckets {
        case ...1:
            self = .high
        case 2:
            self = .normal
        default:
            self = .low
        }
    }

    init(spikeFactor: Double) {
        self =
            Self.allCases.min {
                abs($0.spikeFactor - spikeFactor) < abs($1.spikeFactor - spikeFactor)
            } ?? .normal
    }

    init(silenceFactor: Double) {
        self =
            Self.allCases.min {
                abs($0.silenceFactor - silenceFactor) < abs($1.silenceFactor - silenceFactor)
            } ?? .normal
    }
}
