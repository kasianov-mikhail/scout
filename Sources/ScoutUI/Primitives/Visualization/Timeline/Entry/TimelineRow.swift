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
                    .font(.weight450(size: 12, design: .monospaced))
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
            .font(.weighted(size: label.size, weight: label.weight, design: label.monospaced ? .monospaced : .default))
            .italic(label.italic)
            .foregroundStyle(label.color)
            .lineLimit(1)
    }

    private var chipColor: Color {
        entry.kind.incident?.timelineColor ?? .accentColor
    }
}

#Preview("Rows") {
    VStack(spacing: 0) {
        ForEach(TimelineEntry.samples) { entry in
            TimelineRow(entry: entry)
        }
    }
}
