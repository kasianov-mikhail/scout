//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct EventRow: View {
    let event: Event

    var body: some View {
        Row {
            HStack(spacing: 10) {
                EventLevelGlyph(level: event.level)
                    .frame(width: 16, height: 16)

                Text(verbatim: event.name)
                    .font(.weight450(size: 16, design: .monospaced))
                    .foregroundStyle(event.level == .critical ? criticalNameColor : Color.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let date = event.date {
                    Text(verbatim: eventTimeFormatter.string(from: date))
                        .font(.weight450(size: 13, design: .monospaced))
                        .foregroundStyle(Color(.systemGray))
                        .lineLimit(1)
                        .frame(width: 68, alignment: .trailing)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
        } destination: {
            EventView(event: event)
        }
        .background(cell)
        .padding(.horizontal, -16)
    }

    private var cell: some View {
        (event.level?.color?.opacity(0.12) ?? Color.clear)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 0.5)
                    .padding(.leading, 42)
            }
    }
}

private let eventTimeFormatter = DateFormatter(format: "HH:mm:ss")

private let criticalNameColor = Color(red: 196 / 255, green: 0, blue: 26 / 255)

private struct EventLevelGlyph: View {
    let level: EventLevel?

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
                with: .color(Color(.systemGray)),
                style: StrokeStyle(lineWidth: 1.4, lineCap: .round, dash: [3.76, 2.2, 0.01, 2.2])
            )
        case .debug:
            context.stroke(ring, with: .color(Color(.systemGray)), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
        case .info:
            context.fill(ring, with: .color(Color(.systemGray).opacity(0.35)))
            context.stroke(ring, with: .color(Color(.systemGray)), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
        case .notice:
            context.fill(
                Path(ellipseIn: CGRect(x: 2.8, y: 2.8, width: 14.4, height: 14.4)),
                with: .color(Color(.systemGray))
            )
        case .warning:
            context.stroke(ring, with: .color(Color(.systemYellow)), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
            context.fill(
                Path { path in
                    path.addArc(center: CGPoint(x: 10, y: 10), radius: 6.5, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)
                    path.closeSubpath()
                },
                with: .color(Color(.systemYellow))
            )
        case .error:
            context.fill(ring, with: .color(Color(.systemOrange)))
        case .critical:
            context.fill(ring, with: .color(Color(.systemRed)))
            context.fill(
                Path(ellipseIn: CGRect(x: 7.4, y: 7.4, width: 5.2, height: 5.2)),
                with: .color(.white)
            )
        }
    }
}

#Preview {
    NavigationStack {
        InsetList {
            ForEach(Event.samples.prefix(7)) { event in
                EventRow(event: event)
            }
        }
        .navigationTitle(en: "Events")
    }
    .environmentObject(Tint())
}
