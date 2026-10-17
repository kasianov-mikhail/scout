//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

struct ResourceSummary: Equatable {
    let counts: [ResourceKind: Int]
}

extension ResourceSummary {
    var total: Int {
        counts.values.reduce(0, +)
    }

    var readouts: [ResourceReadout] {
        [
            ResourceReadout(title: "CPU", value: counts[.cpu] ?? 0),
            ResourceReadout(title: "Disk writes", value: counts[.diskWrite] ?? 0),
        ]
    }

    static let sample = ResourceSummary(counts: [.cpu: 7, .diskWrite: 2])
}

struct ResourceReadout: Identifiable {
    let title: String
    let value: Int

    var id: String {
        title
    }
}
