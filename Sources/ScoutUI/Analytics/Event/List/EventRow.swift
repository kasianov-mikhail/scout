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
        NavigationLink {
            EventView(event: event)
        } label: {
            HStack(spacing: .space10) {
                EventLevelGlyph(level: event.level)
                    .frame(width: 16, height: 16)

                Text(verbatim: event.name)
                    .font(.scoutEventName)
                    .foregroundStyle(event.level == .critical ? criticalNameColor : Color.textPrimary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fadingEdge(width: 28)

                if let date = event.date {
                    Text(verbatim: eventTimeFormatter.string(from: date))
                        .font(.scoutValue)
                        .foregroundStyle(Color.textMuted)
                        .lineLimit(1)
                        .frame(width: 68, alignment: .trailing)
                }
            }
            .padding(.horizontal, .gutter)
            .frame(height: .rowRegular)
            .contentShape(.rect)
        }
        .buttonStyle(.solid)
        .background(cell)
        .padding(.horizontal, -16)
    }

    private var cell: some View {
        (event.level?.color?.opacity(0.12) ?? Color.clear)
            .overlay(alignment: .bottom) {
                Separator()
                    .padding(.leading, 42)
            }
    }
}

private let eventTimeFormatter = DateFormatter(format: "HH:mm:ss")

private let criticalNameColor = Color.textDanger

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Event.samples.prefix(7)) { event in
                    EventRow(event: event)
                }
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(en: "Events")
    }
    .environmentObject(Tint())
}
