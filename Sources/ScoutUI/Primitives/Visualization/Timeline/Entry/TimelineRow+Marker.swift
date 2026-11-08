//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension TimelineRow {
    @ViewBuilder
    var marker: some View {
        switch entry.marker {
        case .milestone(let symbol, let color):
            ZStack {
                Circle()
                    .fill(Color.timelineBackground)
                    .frame(width: 26, height: 26)

                Circle()
                    .fill(color)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Image(systemName: symbol)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                    }
            }
            .offset(x: 11, y: entry.height / 2 - 13)
        case .event:
            ZStack {
                Circle()
                    .strokeBorder(Color.timelineSession, lineWidth: 2)
                    .frame(width: 12, height: 12)

                Circle()
                    .fill(Color.timelineBackground)
                    .frame(width: 8, height: 8)
            }
            .offset(x: 42, y: entry.height / 2 - 6)
        case .incident(let kind):
            ZStack {
                Circle()
                    .fill(Color.timelineBackground)
                    .frame(width: 20, height: 20)

                Circle()
                    .strokeBorder(kind.timelineColor, lineWidth: 2)
                    .frame(width: 20, height: 20)

                Image(systemName: kind.timelineSymbol)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(kind.timelineColor)
            }
            .offset(x: entry.session == nil ? 14 : 38, y: entry.height / 2 - 10)
        case nil:
            EmptyView()
        }
    }
}
