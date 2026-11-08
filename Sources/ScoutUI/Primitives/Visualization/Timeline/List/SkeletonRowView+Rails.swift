//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension SkeletonRowView {
    var rails: some View {
        Canvas { context, size in
            switch row.track {
            case .milestone, .event:
                stroke(x: 24, height: size.height, dashed: false, context: &context)
            case .fork:
                stroke(x: 24, height: size.height, dashed: false, context: &context)
                fork(context: &context)
            case .merge:
                stroke(x: 24, height: size.height, dashed: false, context: &context)
                stroke(x: 48, height: size.height, dashed: false, context: &context)
                merge(context: &context)
            case .gap:
                stroke(x: 24, height: size.height, dashed: true, context: &context)
            }

            if row.track == .event {
                stroke(x: 48, height: size.height, dashed: false, context: &context)
            }
        }
        .frame(height: height)
    }

    private func stroke(x: CGFloat, height: CGFloat, dashed: Bool, context: inout GraphicsContext) {
        var path = Path()
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: height))

        context.stroke(
            path,
            with: .color(Color.timelineTrack),
            style: StrokeStyle(lineWidth: 2, dash: dashed ? [4, 4] : [])
        )
    }

    private func fork(context: inout GraphicsContext) {
        var path = Path()
        path.move(to: CGPoint(x: 24, y: 6))
        path.addCurve(to: CGPoint(x: 48, y: 36), control1: CGPoint(x: 24, y: 26), control2: CGPoint(x: 48, y: 14))
        context.stroke(path, with: .color(Color.timelineTrack), style: StrokeStyle(lineWidth: 2))
    }

    private func merge(context: inout GraphicsContext) {
        var path = Path()
        path.move(to: CGPoint(x: 48, y: 0))
        path.addCurve(to: CGPoint(x: 24, y: 30), control1: CGPoint(x: 48, y: 22), control2: CGPoint(x: 24, y: 10))
        context.stroke(path, with: .color(Color.timelineTrack), style: StrokeStyle(lineWidth: 2))
    }
}
