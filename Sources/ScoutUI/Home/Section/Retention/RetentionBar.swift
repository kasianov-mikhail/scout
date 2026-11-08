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
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: width)

                if let rate = week.rate {
                    leftRoundedRectangle
                        .fill(Color.green)
                        .frame(width: width * CGFloat(rate))
                }
            }
        }
        .frame(height: 18)
        .accessibilityHidden(true)
    }

    private var leftRoundedRectangle: AnyShape {
        if #available(iOS 17.0, macOS 14.0, *) {
            AnyShape(UnevenRoundedRectangle(topLeadingRadius: 3, bottomLeadingRadius: 3))
        } else {
            AnyShape(RoundedRectangle(cornerRadius: 3))
        }
    }
}

#Preview {
    VStack {
        RetentionBar(week: [RetentionWeek].samples[1], maxInstalls: 1142)
        RetentionBar(week: [RetentionWeek].samples[0], maxInstalls: 1142)
    }
    .padding()
}
