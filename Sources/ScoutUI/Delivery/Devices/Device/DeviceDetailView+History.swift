//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HistoryRow: View {
    let event: DeviceHistoryEvent
    let isLast: Bool

    var body: some View {
        HStack(spacing: .space12) {
            ZStack {
                if !isLast {
                    Rectangle()
                        .fill(Color.surfaceBarIdle)
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .offset(y: 22)
                }

                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
            .frame(width: 8, height: 44)

            Text(verbatim: event.dateText)
                .font(.scoutValue)
                .monospacedDigit()
                .foregroundStyle(Color.textMuted)
                .frame(width: 56, alignment: .leading)

            (Text(verbatim: event.title)
                + Text(verbatim: event.version.map { " " + $0 } ?? "")
                .font(.scoutValueStrong))
                .font(.scoutRow)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .lineLimit(1)
        .frame(height: .rowRegular)
    }

    private var color: Color {
        switch event.kind {
        case .installed, .reinstalled:
            .deviceAccent
        case .updated:
            .fillAccent
        case .os:
            Color.fillLevel
        }
    }
}
