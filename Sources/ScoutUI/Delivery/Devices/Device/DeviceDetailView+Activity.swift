//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct DeviceActivityChart: View {
    let points: [DeviceActivityPoint]
    let showsCounts: Bool

    var body: some View {
        let maxCount = points.map(\.count).max() ?? 0

        HStack(alignment: .bottom, spacing: .space6) {
            ForEach(points) { point in
                VStack(spacing: .space4) {
                    if showsCounts {
                        Text(verbatim: point.count > 0 ? "\(point.count)" : "—")
                            .font(.scoutAxis)
                            .monospacedDigit()
                            .foregroundStyle(point.count > 0 ? Color.fillLevel : Color.pending)
                            .lineLimit(1)
                    }

                    VStack {
                        Spacer(minLength: 0)
                        RoundedRectangle(cornerRadius: .radiusBlock)
                            .fill(color(for: point))
                            .frame(height: height(for: point, maxCount: maxCount))
                    }
                    .frame(height: 56)

                    Text(verbatim: point.showsLabel ? point.label : "")
                        .font(point.isCurrent ? .system(size: 10, weight: .semibold) : .book(size: 10))
                        .foregroundStyle(point.isCurrent ? Color.textPrimary : Color.fillLevel)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Sessions per period"))
    }

    private func height(for point: DeviceActivityPoint, maxCount: Int) -> CGFloat {
        guard maxCount > 0, point.count > 0 else {
            return 1
        }
        return max(2, 56 * CGFloat(point.count) / CGFloat(maxCount))
    }

    private func color(for point: DeviceActivityPoint) -> Color {
        guard point.count > 0 else {
            return Color.surfaceSkeleton
        }
        return point.isCurrent ? .deviceAccent : .deviceAccentSoft
    }
}
