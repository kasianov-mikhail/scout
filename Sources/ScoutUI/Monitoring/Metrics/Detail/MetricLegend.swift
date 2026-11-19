//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricLegend: View {
    let title: String
    let note: String?

    var body: some View {
        HStack(spacing: .space12) {
            HStack(spacing: .space4) {
                MetricDashedSample()
                Text(verbatim: title)
            }

            if let note {
                Text(verbatim: note)
                    .lineLimit(2)
            }
        }
        .font(.scoutFootnote)
        .foregroundStyle(Color.textMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .space10)
        .padding(.bottom, .space16)
    }
}

private struct MetricDashedSample: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 1))
                path.addLine(to: CGPoint(x: proxy.size.width, y: 1))
            }
            .stroke(Color.lineSeparator, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
        }
        .frame(width: 16, height: 2)
    }
}
