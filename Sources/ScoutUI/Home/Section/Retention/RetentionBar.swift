//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RetentionBar: View {
    let week: RetentionWeek
    let maxInstalls: Int

    var body: some View {
        GeometryReader { proxy in
            let width = maxInstalls > 0 ? proxy.size.width * CGFloat(week.installs) / CGFloat(maxInstalls) : 0

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: .radiusBlock)
                    .fill(Color.surfaceSkeleton)
                    .frame(width: width)

                if let rate = week.rate {
                    LeftRoundedRectangle(cornerRadius: .radiusBlock)
                        .fill(Color.fillSuccess)
                        .frame(width: width * CGFloat(rate))
                }
            }
        }
        .frame(height: 18)
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack {
        RetentionBar(week: [RetentionWeek].samples[1], maxInstalls: 1142)
        RetentionBar(week: [RetentionWeek].samples[0], maxInstalls: 1142)
    }
    .padding()
}
