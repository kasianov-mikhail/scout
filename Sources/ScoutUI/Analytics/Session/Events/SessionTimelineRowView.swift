//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct SessionTimelineRowView: View {
    let row: SessionTimelineRow

    var body: some View {
        Group {
            if isNavigable {
                NavigationLink {
                    destination
                } label: {
                    content
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var content: some View {
        ZStack(alignment: .topLeading) {
            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: 24, y: railTop))
                path.addLine(to: CGPoint(x: 24, y: min(railBottom, size.height)))

                context.stroke(
                    path,
                    with: .color(railColor),
                    style: StrokeStyle(lineWidth: 2, dash: railDashed ? [4, 4] : [])
                )
            }

            marker

            HStack(spacing: 8) {
                Text(verbatim: row.title)
                    .font(titleFont)
                    .italic(isGap)
                    .foregroundStyle(titleColor)
                    .lineLimit(1)
                    .layoutPriority(isGap ? 0 : 1)

                if let subtitle = row.subtitle {
                    Text(verbatim: subtitle)
                        .font(subtitleFont)
                        .foregroundStyle(Color.timelineMuted)
                        .lineLimit(1)
                        .layoutPriority(-1)
                }

                if let level = row.level {
                    chip(level.sessionLabel, level: level)
                }

                Spacer(minLength: 8)

                if let time = row.time {
                    Text(verbatim: time)
                        .font(.book(size: 12, design: .monospaced))
                        .foregroundStyle(Color.timelineMuted)
                        .layoutPriority(1)
                }
            }
            .padding(.leading, 56)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: row.height)
        .background(tint ?? Color.clear)
    }

    private var isNavigable: Bool {
        switch row.kind {
        case .event, .crash, .hang, .resource:
            true
        default:
            false
        }
    }

    @ViewBuilder
    private var destination: some View {
        switch row.kind {
        case .event(let event):
            EventView(event: event)
        case .crash(let crash):
            CrashDetailView(crash: crash)
        case .hang(let hang):
            HangDetailView(hang: hang)
        case .resource(let resource):
            ResourceDetailView(resource: resource)
        default:
            EmptyView()
        }
    }
}
