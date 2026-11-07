//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct VersionMetricTile: View {
    let metric: VersionMetric
    let value: String
    let color: Color
    let footnote: String
    let chart: VersionMetricChart
    let leading: Bool
    let action: (() -> Void)?

    var body: some View {
        if let action {
            Button(action: action) {
                cell
            }
            .buttonStyle(.plain)
        } else {
            cell
        }
    }

    private var cell: some View {
        VersionMetricCell(title: metric.title, leading: leading) {
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                VersionMetricChartView(chart: chart)
                    .frame(height: 24)

                Text(verbatim: footnote)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(height: 14, alignment: .leading)
            }
        }
        .contentShape(Rectangle())
    }
}

struct VersionMetricCell<Content: View>: View {
    let title: String
    let leading: Bool

    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: title)
                .font(.system(size: 13))
                .foregroundStyle(Color(.systemGray))

            content()
        }
        .padding(EdgeInsets(top: 14, leading: leading ? 0 : 12, bottom: 14, trailing: leading ? 12 : 0))
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Color.separator
                .frame(height: 0.5)
        }
        .overlay(alignment: .trailing) {
            if leading {
                Color.separator
                    .frame(width: 0.5)
            }
        }
    }
}
