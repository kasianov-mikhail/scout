//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

struct Metric: View {
    let title: String
    let value: String
    var color: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: value)
                .font(.title2.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(color)
            Text(verbatim: title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.gray)
        }
    }
}

extension Metric {
    init(title: String, stability: Stability) {
        self.init(title: title, value: stability.formatted, color: stability.color)
    }
}
