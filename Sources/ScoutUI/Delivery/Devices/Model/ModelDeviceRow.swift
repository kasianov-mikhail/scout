//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ModelDeviceRow: View {
    let device: DeviceSummary
    let maxSessions: Int

    var body: some View {
        HStack(spacing: .space8) {
            Text(verbatim: device.lastSeen.relativeString)
                .font(.scoutCaption)
                .lineLimit(1)
                .frame(width: 84, alignment: .leading)

            BarValue(text: device.sessions.compact, fraction: share, color: .deviceTrack, barHeight: 25.5)
                .frame(height: 18)

            Text(verbatim: osVersion)
                .font(.scoutCode)
                .foregroundStyle(Color.textMuted)
                .lineLimit(1)
                .frame(width: 44, alignment: .leading)

            Text(verbatim: device.crashes > 0 ? "\(device.crashes)" : "—")
                .font(device.crashes > 0 ? .scoutValueStrong : .scoutValue)
                .monospacedDigit()
                .foregroundStyle(device.crashes > 0 ? Color.crashText : Color.pending)
                .frame(width: 56, alignment: .trailing)
        }
        .lineLimit(1)
        .frame(height: .rowTable)
        .overlay(alignment: .bottom) {
            Separator.dashed
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
    }

    private var osVersion: String {
        DeviceOSRange(versions: [device.osVersion]).shortLabel ?? device.osVersion
    }

    private var share: Double {
        maxSessions > 0 ? Double(device.sessions) / Double(maxSessions) : 0
    }
}
