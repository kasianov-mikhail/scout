//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TimelineRails: View {
    let entry: TimelineEntry

    var body: some View {
        Canvas { context, size in
            if let launch = entry.launch {
                stroke(
                    lane: launch,
                    x: 24,
                    height: size.height,
                    context: &context
                )
            }

            if let session = entry.session {
                stroke(
                    lane: session,
                    x: 48,
                    height: size.height,
                    context: &context
                )
            }

            if let connector = entry.connector {
                connectorPath(connector, context: &context)
            }
        }
        .frame(height: entry.height)
        .allowsHitTesting(false)
    }

    private func stroke(lane: TimelineEntry.Lane, x: CGFloat, height: CGFloat, context: inout GraphicsContext) {
        let top = lane.top
        let bottom = height - lane.bottom

        guard bottom > top else {
            return
        }

        let split = lane.split.map { min(max($0.y, top), bottom) } ?? bottom
        stroke(x: x, top: top, bottom: split, color: lane.color, dashed: lane.dashed, context: &context)

        if let splitColor = lane.split?.color {
            stroke(x: x, top: split, bottom: bottom, color: splitColor, dashed: lane.dashed, context: &context)
        }
    }

    private func stroke(x: CGFloat, top: CGFloat, bottom: CGFloat, color: Color, dashed: Bool, context: inout GraphicsContext) {
        var path = Path()
        path.move(to: CGPoint(x: x, y: top))
        path.addLine(to: CGPoint(x: x, y: bottom))

        context.stroke(
            path,
            with: .color(color),
            style: StrokeStyle(lineWidth: 2, dash: dashed ? [4, 4] : [])
        )
    }

    private func connectorPath(_ connector: TimelineEntry.Connector, context: inout GraphicsContext) {
        switch connector {
        case .fork:
            var path = Path()
            path.move(to: CGPoint(x: 24, y: 6))
            path.addCurve(to: CGPoint(x: 48, y: 36), control1: CGPoint(x: 24, y: 26), control2: CGPoint(x: 48, y: 14))

            context.stroke(path, with: .color(Color.timelineSession), style: StrokeStyle(lineWidth: 2))
            context.fill(
                Path(ellipseIn: CGRect(x: 21, y: 3, width: 6, height: 6)),
                with: .color(Color.timelineSession)
            )
        case .merge(let color, let dashed):
            var path = Path()
            path.move(to: CGPoint(x: 48, y: 0))
            path.addCurve(to: CGPoint(x: 24, y: 30), control1: CGPoint(x: 48, y: 22), control2: CGPoint(x: 24, y: 10))

            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(lineWidth: 2, dash: dashed ? [4, 4] : [])
            )
            context.fill(
                Path(ellipseIn: CGRect(x: 21, y: 27, width: 6, height: 6)),
                with: .color(color)
            )
        case .loop(let color):
            var path = Path()
            path.move(to: CGPoint(x: 24, y: 8))
            path.addCurve(to: CGPoint(x: 48, y: 22), control1: CGPoint(x: 24, y: 18), control2: CGPoint(x: 48, y: 12))
            path.addCurve(to: CGPoint(x: 24, y: 36), control1: CGPoint(x: 48, y: 32), control2: CGPoint(x: 24, y: 26))

            context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 2))
            context.fill(
                Path(ellipseIn: CGRect(x: 21, y: 5, width: 6, height: 6)),
                with: .color(color)
            )
            context.fill(
                Path(ellipseIn: CGRect(x: 21, y: 33, width: 6, height: 6)),
                with: .color(color)
            )
        }
    }
}
