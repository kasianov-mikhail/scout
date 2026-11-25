//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension DeviceDetailView {
    func stats(_ detail: DeviceDetail) -> some View {
        HStack(spacing: 0) {
            stat("crashes", value: detail.crashes, color: .crashText, divider: true, leading: 0, trailing: 10)
            stat("hangs", value: detail.hangs, color: .hangText, divider: true, leading: 10, trailing: 10)
            stat("resources", value: detail.resources, color: .resourceText, divider: false, leading: 10, trailing: 0)
        }
        .padding(.bottom, .space6)
    }

    func stat(_ title: String, value: Int, color: Color, divider: Bool, leading: CGFloat, trailing: CGFloat) -> some View {
        StatColumn(title: title, leading: leading, trailing: trailing, divider: divider) {
            Text(verbatim: "\(value)")
                .font(.scoutNumberL)
                .monospacedDigit()
                .foregroundStyle(value > 0 ? color : Color.textPrimary)
        }
    }
}

struct StatColumn<Value: View>: View {
    let title: String
    let leading: CGFloat
    let trailing: CGFloat
    var divider = true

    @ViewBuilder let value: () -> Value

    var body: some View {
        VStack(alignment: .leading, spacing: .space2) {
            value()

            Text(verbatim: title)
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)
        }
        .padding(.vertical, .space12)
        .padding(.leading, leading)
        .padding(.trailing, trailing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            if divider {
                Separator(axis: .vertical)
            }
        }
    }
}

struct SessionLine: View {
    let session: DeviceSession
    let maxDuration: TimeInterval
    let showsDivider: Bool

    var body: some View {
        HStack(spacing: .space8) {
            Circle()
                .fill(session.crashed ? Color.textDanger : Color.clear)
                .frame(width: 8, height: 8)

            Text(verbatim: session.time)
                .font(.scoutValue)
                .monospacedDigit()
                .lineLimit(1)
                .frame(width: 76, alignment: .leading)

            BarValue(text: session.durationText ?? "—", fraction: share, color: .deviceTrack, barHeight: 25.5)
                .frame(height: 18)

            Text(verbatim: session.appVersion ?? "—")
                .font(.scoutCode)
                .monospacedDigit()
                .foregroundStyle(Color.textMuted)
                .lineLimit(1)
                .frame(width: 44, alignment: .trailing)
        }
        .lineLimit(1)
        .frame(height: .rowRegular)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Separator.dashed
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
    }

    private var share: Double {
        guard let duration = session.duration, maxDuration > 0 else {
            return 0
        }
        return duration / maxDuration
    }
}
