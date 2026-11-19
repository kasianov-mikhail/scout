//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct ActiveUserMetricView: View {
    let metric: ActiveUsersMetric
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: metric.kind.title.uppercased())
                .font(.scoutCaptionStrong)
                .foregroundStyle(isActive ? Color.textPrimary : Color.textMuted)

            Text(verbatim: metric.valueLabel)
                .font(.scoutNumberL)
                .foregroundStyle(isActive ? Color.textPrimary : Color.inactiveValue)
                .frame(height: 34, alignment: .leading)

            Text(verbatim: metric.deltaLabel)
                .font(.scoutCaption)
                .foregroundStyle(metric.delta >= 0 ? Color.positive : Color.fillDanger)
        }
        .padding(.vertical, .space10)
    }
}
