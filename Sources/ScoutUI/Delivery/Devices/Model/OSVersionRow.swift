//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct OSVersionRow: View {
    let osVersion: DeviceOSUsage
    let color: Color
    let showsDivider: Bool

    var body: some View {
        HStack(spacing: .space8) {
            RoundedRectangle(cornerRadius: .radiusBar)
                .fill(color)
                .frame(width: 8, height: 8)
                .frame(width: 14, alignment: .leading)

            (Text(verbatim: osVersion.version).font(.scoutValueStrong)
                + Text(verbatim: " · \(osVersion.devices) \(osVersion.devices == 1 ? "device" : "devices")")
                .font(.scoutCaption)
                .foregroundColor(Color.textMuted))
                .font(.scoutValue)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(verbatim: osVersion.sessions.compact)
                .font(.scoutValue)
                .monospacedDigit()
                .frame(width: 72, alignment: .trailing)

            Text(verbatim: osVersion.percentageText)
                .font(.scoutValue)
                .monospacedDigit()
                .foregroundStyle(Color.textMuted)
                .frame(width: 56, alignment: .trailing)
        }
        .lineLimit(1)
        .frame(height: .rowTable)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Separator.dashed
            }
        }
    }
}

func deviceOSColor(_ index: Int) -> Color {
    let colors: [Color] = [.deviceAccent, .deviceAccentSoft, .deviceTrack]
    return colors[index % colors.count]
}
