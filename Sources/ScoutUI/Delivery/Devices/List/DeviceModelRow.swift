//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct DeviceModelRow: View {
    let model: DeviceModelSummary
    let maxSessions: Int

    var body: some View {
        VStack(alignment: .leading, spacing: .space8) {
            HStack(spacing: .space8) {
                Image(systemName: model.symbol)
                    .foregroundStyle(Color.textLink)
                    .frame(width: 20)

                Text(verbatim: model.name)
                    .font(.scoutRow)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(verbatim: "\(model.devices) \(model.devices == 1 ? "device" : "devices")")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
            }

            HStack(spacing: .space8) {
                BarValue(text: model.sessions.compact, fraction: share, color: .deviceTrack, barHeight: 25.5)
                    .frame(height: 18)

                Text(verbatim: model.osLabel ?? "—")
                    .font(.scoutCode)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
                    .frame(width: 112, alignment: .leading)

                Text(verbatim: model.crashes > 0 ? "\(model.crashes)" : "—")
                    .font(model.crashes > 0 ? .scoutValueStrong : .scoutValue)
                    .monospacedDigit()
                    .foregroundStyle(model.crashes > 0 ? Color.crashText : Color.pending)
                    .frame(width: 56, alignment: .trailing)
            }
        }
        .lineLimit(1)
        .frame(height: .rowChart)
        .overlay(alignment: .bottom) {
            Separator.dashed
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }

    private var share: Double {
        maxSessions > 0 ? Double(model.sessions) / Double(maxSessions) : 0
    }
}
