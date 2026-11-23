//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct EventLevelGlyph: View {
    let level: EventLevel?
    var style = Style.row

    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 20, y: size.width / 20)
            draw(in: &context)
        }
        .accessibilityElement()
        .accessibilityLabel(Text(verbatim: (level ?? .info).description))
    }

    private func draw(in context: inout GraphicsContext) {
        let ring = Path(ellipseIn: CGRect(x: 3.5, y: 3.5, width: 13, height: 13))

        switch level ?? .info {
        case .trace:
            context.stroke(
                ring,
                with: .color(style.level),
                style: StrokeStyle(lineWidth: style.ring, lineCap: .round, dash: [3.76, 2.2, 0.01, 2.2])
            )
        case .debug:
            context.stroke(ring, with: .color(style.level), style: StrokeStyle(lineWidth: style.ring, lineCap: .round))
        case .info:
            context.fill(ring, with: .color(style.level.opacity(0.35)))
            context.stroke(ring, with: .color(style.level), style: StrokeStyle(lineWidth: style.ring, lineCap: .round))
        case .notice:
            context.fill(
                Path(ellipseIn: CGRect(x: 2.8, y: 2.8, width: 14.4, height: 14.4)),
                with: .color(style.level)
            )
        case .warning:
            context.stroke(ring, with: .color(style.caution), style: StrokeStyle(lineWidth: .iconStroke, lineCap: .round))
            context.fill(
                Path { path in
                    path.addArc(center: CGPoint(x: 10, y: 10), radius: 6.5, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)
                    path.closeSubpath()
                },
                with: .color(style.caution)
            )
        case .error:
            context.fill(ring, with: .color(style.warning))
        case .critical:
            context.fill(ring, with: .color(style.danger))
            context.fill(
                Path(ellipseIn: CGRect(x: 7.4, y: 7.4, width: 5.2, height: 5.2)),
                with: .color(.white)
            )
        }
    }

    struct Style {
        let level: Color
        let caution: Color
        let warning: Color
        let danger: Color
        let ring: CGFloat

        static let row = Style(
            level: .fillLevel,
            caution: .textCaution,
            warning: .textWarning,
            danger: .textDanger,
            ring: .iconStroke
        )

        static let updates = Style(
            level: .fillLevel,
            caution: .fillCaution,
            warning: .fillWarning,
            danger: .fillDanger,
            ring: 1.4
        )
    }
}

#Preview {
    HStack(spacing: .space12) {
        ForEach(EventLevel.allCases.reversed(), id: \.self) { level in
            EventLevelGlyph(level: level)
                .frame(width: 16, height: 16)
        }
    }
    .padding()
}
