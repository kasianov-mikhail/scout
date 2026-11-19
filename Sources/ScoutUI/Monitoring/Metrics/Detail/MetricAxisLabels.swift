//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

private let monospacedAdvance: CGFloat = 6

struct MetricAxisLabels: View {
    let labels: [MetricAxisLabel]

    var body: some View {
        GeometryReader { proxy in
            ForEach(labels.indices, id: \.self) { index in
                Text(verbatim: labels[index].text)
                    .position(x: x(labels[index], width: proxy.size.width), y: proxy.size.height / 2)
            }
        }
        .frame(height: 12)
        .padding(.top, .space4)
        .font(.scoutAxis)
        .foregroundStyle(Color.textMuted)
    }

    private func x(_ label: MetricAxisLabel, width: CGFloat) -> CGFloat {
        let half = CGFloat(label.text.count) * monospacedAdvance / 2
        return min(max(width * CGFloat(label.position), half), width - half)
    }
}
