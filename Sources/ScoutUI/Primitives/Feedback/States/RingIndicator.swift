//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RingIndicator: View {
    static let lineWidth: CGFloat = 3

    var size: CGFloat = 44

    var body: some View {
        Circle()
            .stroke(Color(white: 0.8), lineWidth: Self.lineWidth)
            .overlay { arc }
            .frame(width: size, height: size)
    }

    private var arc: some View {
        TimelineView(.animation) { context in
            blueArc.rotationEffect(.degrees(context.date.timeIntervalSinceReferenceDate * 400))
        }
    }

    private var blueArc: some View {
        Circle()
            .trim(from: 0, to: 0.3)
            .stroke(.blue, style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round))
    }
}

#Preview {
    RingIndicator()
}
