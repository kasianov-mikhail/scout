//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct IncidentContextRow: View {
    let systemImage: String
    let color: Color
    let label: String?
    let value: String?
    let skeleton: Bool
    let showsDivider: Bool
    let delay: Double

    var body: some View {
        HStack(spacing: .space10) {
            if skeleton {
                SkeletonBar(width: 18, height: 18, delay: delay, cornerRadius: .radiusBadge)
                    .frame(width: 24)
            } else {
                Image(systemName: systemImage)
                    .font(.scoutRow)
                    .frame(width: 24)
                    .foregroundStyle(color)
            }

            if skeleton, label == nil {
                SkeletonBar(width: 88, height: 9, delay: delay)
            } else if let label {
                Text(verbatim: label)
                    .font(.scoutRow)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if skeleton, value == nil {
                SkeletonBar(width: 74, height: 9, delay: delay)
            } else if let value {
                Text(verbatim: value)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
            }
        }
        .lineLimit(1)
        .frame(height: .rowRegular)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if showsDivider {
                Separator.dashed
            }
        }
    }
}
