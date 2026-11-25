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
            let fraction = maxInstalls > 0 ? CGFloat(week.installs) / CGFloat(maxInstalls) : 0
            let width = proxy.size.width * fraction

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: .radiusBlock)
                    .fill(Color.surfaceSkeleton)
                    .frame(width: width)

                LeftRoundedRectangle(cornerRadius: .radiusBlock)
                    .fill(Color.fillSuccess)
                    .frame(width: width * CGFloat(week.rate ?? 0))
            }
            .animation(.barResize, value: fraction)
            .animation(.barResize, value: week.rate)
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
