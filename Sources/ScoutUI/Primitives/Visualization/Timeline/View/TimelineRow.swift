//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TimelineRow: View {
    let entry: TimelineEntry

    var body: some View {
        ZStack(alignment: .topLeading) {
            TimelineRails(entry: entry)

            marker

            content
        }
        .frame(height: entry.height)
        .background {
            if let tint = entry.tint {
                tint
            }
        }
        .background {
            if entry.isFocused {
                GeometryReader { geometry in
                    Color.clear.preference(key: AnchorFrameKey.self, value: geometry.frame(in: .global))
                }
            }
        }
        .overlay(alignment: .bottom) {
            if entry.showsSeparator {
                Rectangle()
                    .fill(Color.timelineSeparator)
                    .frame(height: 1)
                    .padding(.leading, 72)
                    .padding(.trailing, 16)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var content: some View {
        HStack(spacing: 8) {
            text(entry.title)

            if let subtitle = entry.subtitle {
                text(subtitle)
                    .layoutPriority(-1)
            }

            if let chip = entry.chip {
                Text(verbatim: chip)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(chipColor))
            }

            Spacer(minLength: 8)

            if let time = entry.time {
                Text(verbatim: time)
                    .font(.system(size: 12))
                    .monospaced()
                    .foregroundStyle(Color.timelineMuted)
                    .layoutPriority(1)
            }
        }
        .padding(.leading, 72)
        .padding(.trailing, 16)
        .frame(height: entry.height)
    }

    private func text(_ label: TimelineEntry.Label) -> some View {
        Text(verbatim: label.text)
            .font(.system(size: label.size, weight: label.weight))
            .monospaced(label.monospaced)
            .italic(label.italic)
            .foregroundStyle(label.color)
            .lineLimit(1)
    }

    private var chipColor: Color {
        entry.kind.incident?.timelineColor ?? .accentColor
    }

    @ViewBuilder
    private var marker: some View {
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

private struct TimelineRails: View {
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

        var path = Path()
        path.move(to: CGPoint(x: x, y: top))
        path.addLine(to: CGPoint(x: x, y: bottom))

        context.stroke(
            path,
            with: .color(lane.color),
            style: StrokeStyle(lineWidth: 2, dash: lane.dashed ? [4, 4] : [])
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

#Preview("Rows") {
    VStack(spacing: 0) {
        TimelineRow(
            entry: TimelineEntry(
                id: "install",
                kind: .install,
                height: 44,
                launch: .init(color: .timelinePending, dashed: true, top: 22, bottom: 0),
                session: nil,
                connector: nil,
                marker: .milestone(symbol: "arrow.down.to.line", color: .timelineInstall),
                title: .init(text: "App installed", size: 15, weight: .semibold, color: .primary),
                subtitle: .init(text: "Oct 14", size: 13, weight: .regular, color: .timelineMuted),
                time: "10:02",
                chip: nil,
                tint: nil
            )
        )

        TimelineRow(
            entry: TimelineEntry(
                id: "launch",
                kind: .launch,
                height: 44,
                launch: .init(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: nil,
                connector: nil,
                marker: .milestone(symbol: "play.fill", color: .timelineLaunch),
                title: .init(text: "App launched", size: 15, weight: .semibold, color: .primary),
                subtitle: .init(text: "Oct 14 · 2.4.0", size: 13, weight: .regular, color: .timelineMuted),
                time: "10:02",
                chip: nil,
                tint: nil
            )
        )

        TimelineRow(
            entry: TimelineEntry(
                id: "fork",
                kind: .fork,
                height: 36,
                launch: .init(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: nil,
                connector: .fork,
                marker: nil,
                title: .init(text: "Session", size: 13, weight: .semibold, color: .timelineSessionInk),
                subtitle: .init(text: "3m 10s", size: 13, weight: .regular, color: .timelineMuted),
                time: "10:02",
                chip: nil,
                tint: nil
            )
        )

        TimelineRow(
            entry: TimelineEntry(
                id: "event",
                kind: .event,
                height: 44,
                launch: .init(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: .init(color: .timelineSession, dashed: false, top: 0, bottom: 0),
                connector: nil,
                marker: .event,
                title: .init(text: "app_open", size: 16, weight: .regular, color: .primary, monospaced: true),
                subtitle: nil,
                time: "10:02:05",
                chip: nil,
                tint: nil,
                showsSeparator: true
            )
        )

        TimelineRow(
            entry: TimelineEntry(
                id: "crash",
                kind: .crash,
                height: 44,
                launch: .init(color: .timelineLaunch, dashed: false, top: 0, bottom: 0),
                session: .init(color: .timelineSession, dashed: false, top: 0, bottom: 0),
                connector: nil,
                marker: .incident(.crash),
                title: .init(text: "Crash", size: 16, weight: .semibold, color: .timelineCrashInk),
                subtitle: .init(text: "SIGABRT", size: 13, weight: .regular, color: .timelineMuted, monospaced: true),
                time: "10:05:15",
                chip: "This crash",
                tint: Color.timelineCrash.opacity(0.1)
            )
        )

        TimelineRow(
            entry: TimelineEntry(
                id: "merge",
                kind: .merge,
                height: 36,
                launch: .init(color: .timelineLaunch, dashed: false, top: 0, bottom: 6),
                session: .init(color: .timelineSession, dashed: false, top: 0, bottom: 0),
                connector: .merge(color: .timelineCrash, dashed: false),
                marker: nil,
                title: .init(text: "App crashed", size: 13, weight: .semibold, color: .timelineCrashInk),
                subtitle: nil,
                time: "10:05",
                chip: nil,
                tint: nil
            )
        )

        TimelineRow(
            entry: TimelineEntry(
                id: "gap",
                kind: .gap,
                height: 36,
                launch: .init(color: .timelinePending, dashed: true, top: 0, bottom: 0),
                session: nil,
                connector: nil,
                marker: nil,
                title: .init(text: "3 h", size: 13, weight: .regular, color: .timelineMuted, italic: true),
                subtitle: nil,
                time: nil,
                chip: nil,
                tint: nil
            )
        )
    }
}
