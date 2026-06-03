//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TimelineRow<Rails: View>: View {
    let color: Color
    let name: String
    let date: Date
    let timeline: Date

    @ViewBuilder let rails: () -> Rails

    var body: some View {
        HStack(spacing: 4) {
            rails()

            Text(name)
                .font(.system(size: 17))
                .lineLimit(1)
                .monospaced()
                .foregroundStyle(color)
                .padding(.leading, 8)

            Spacer()

            TimelineView(.periodic(from: timeline, by: 1)) { _ in
                Text(date.relativeString)
            }
            .font(.system(size: 15))
            .foregroundStyle(.gray)
        }
        .frame(height: 43)
    }
}
