//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct IncidentAffectedRow: View {
    let affected: IncidentAffected

    var body: some View {
        VStack(alignment: .leading, spacing: .space8) {
            HStack {
                Text(verbatim: affected.title)
                    .font(.scoutRow)

                Spacer()

                Text(verbatim: "\(affected.total)")
                    .font(.scoutRow)
                    .monospacedDigit()
                    .foregroundStyle(Color.textMuted)
            }

            bar

            ViewThatFits(in: .horizontal) {
                legend(visible: affected.segments.count)
                legend(visible: affected.segments.count - 1)
                legend(visible: affected.segments.count - 2)
                legend(visible: affected.segments.count - 3)
                legend(visible: affected.segments.count - 4)
            }
        }
        .padding(.vertical, .space16)
    }

    private func legend(visible count: Int) -> some View {
        let visible = min(max(count, 1), affected.segments.count)

        return HStack(spacing: .space12) {
            ForEach(affected.segments.prefix(visible)) { segment in
                HStack(spacing: .space4) {
                    Circle()
                        .fill(segment.color)
                        .frame(width: 7, height: 7)

                    Text(verbatim: label(segment: segment))
                        .lineLimit(1)
                }
            }

            if affected.segments.count > visible {
                Text(verbatim: "+\(affected.segments.count - visible)")
            }
        }
        .font(.scoutFootnote)
        .foregroundStyle(Color.textMuted)
        .fixedSize(horizontal: true, vertical: false)
    }

    private var bar: some View {
        GeometryReader { proxy in
            let gaps = CGFloat(max(affected.segments.count - 1, 0)) * 2
            let width = max(proxy.size.width - gaps, 0)

            HStack(spacing: .space2) {
                ForEach(affected.segments) { segment in
                    Rectangle()
                        .fill(segment.color)
                        .frame(width: width * share(segment: segment))
                }
            }
        }
        .frame(height: 8)
        .clipShape(RoundedRectangle(cornerRadius: .radiusBadge))
    }

    private func label(segment: Segment) -> String {
        affected.usesDeviceNames ? DeviceModel(identifier: segment.label).name : segment.label
    }

    private func share(segment: Segment) -> CGFloat {
        guard affected.total > 0 else {
            return 0
        }
        return CGFloat(segment.count) / CGFloat(affected.total)
    }
}
