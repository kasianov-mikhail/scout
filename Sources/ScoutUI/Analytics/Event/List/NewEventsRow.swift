//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct NewEventsRow: View {
    let counts: [EventLevel: Int]
    var hasMore = false
    let show: () -> Void

    @State private var isFlashing = true

    var body: some View {
        Button(action: show) {
            HStack(spacing: 12) {
                GeometryReader { geometry in
                    HStack(spacing: 12) {
                        ForEach(severityOrder, id: \.self) { level in
                            if let count = counts[level] {
                                HStack(spacing: 4) {
                                    EventLevelGlyph(level: level)
                                        .frame(width: 16, height: 16)
                                    Text(verbatim: format(count))
                                        .font(.scoutValue)
                                        .foregroundStyle(Color.textPrimary)
                                }
                            }
                        }
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                    .fadingEdge(width: min(36, geometry.size.width))
                }
                .accessibilityHidden(true)

                Text(verbatim: title)
                    .font(.scoutRowStrong)
                    .foregroundStyle(Color.textLink)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, .gutter)
            .frame(height: .rowRegular)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .background {
            Color.surfaceTrack
                .overlay(flashColor.opacity(isFlashing ? 1 : 0))
        }
        .overlay(alignment: .bottom) { Separator() }
        .accessibilityLabel(Text(verbatim: title))
        .accessibilityValue(Text(verbatim: severitySummary))
        .task {
            guard (try? await Task.sleep(for: .milliseconds(490))) != nil else {
                return
            }
            withAnimation(.easeOut(duration: 0.91)) {
                isFlashing = false
            }
        }
    }

    private var title: String {
        let count = format(counts.values.reduce(0, +))
        return "Show \(count)\(hasMore ? "+" : "") new"
    }

    private var severitySummary: String {
        severityOrder.compactMap { level in counts[level].map { "\(level.description) \(format($0))" } }
            .joined(separator: ", ")
    }

    private func format(_ count: Int) -> String {
        count.formatted(.number.locale(Locale(identifier: "en_US")))
    }
}

private let severityOrder: [EventLevel] = [.critical, .error, .warning, .notice, .info, .debug, .trace]
private let flashColor = designColor(light: 0xD3E4FF, dark: 0x154171)

#Preview("By severity") {
    NewEventsRow(counts: [.critical: 1, .error: 2, .warning: 1, .info: 8]) {}
        .dynamicTypeSize(.large)
}

#Preview("Overflow") {
    NewEventsRow(counts: [.critical: 1, .error: 3, .warning: 12, .notice: 24, .info: 186, .debug: 412, .trace: 1_038]) {}
        .dynamicTypeSize(.large)
}
