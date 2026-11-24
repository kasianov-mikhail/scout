//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct EventUpdatesBar: View {
    let counts: [EventLevel: Int]
    var hasMore = false
    let show: () -> Void

    @State private var isFlashing = true

    var body: some View {
        Button(action: show) {
            HStack(spacing: .space12) {
                severityCounts
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .fadingEdge(width: 36)

                Text(verbatim: title)
                    .font(.scoutRowStrong)
                    .foregroundStyle(Color.textLink)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, .gutter)
            .frame(height: .rowRegular)
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .background(isFlashing ? flashColor : Color.surfaceTrack)
        .overlay(alignment: .bottom) {
            Separator()
        }
        .frame(height: counts.isEmpty ? 0 : .rowRegular)
        .clipped()
        .opacity(counts.isEmpty ? 0 : 1)
        .allowsHitTesting(!counts.isEmpty)
        .accessibilityHidden(counts.isEmpty)
        .accessibilityLabel(Text(verbatim: title))
        .accessibilityValue(Text(verbatim: severitySummary))
        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.36), value: counts.isEmpty)
        .task(id: counts.isEmpty) {
            await flash()
        }
    }

    private var severityCounts: some View {
        HStack(spacing: .space12) {
            ForEach(severityOrder, id: \.self) { level in
                if let count = counts[level] {
                    HStack(spacing: .space4) {
                        EventLevelGlyph(level: level, style: .updates)
                            .frame(width: 16, height: 16)
                        Text(verbatim: format(count))
                            .font(.scoutValue)
                            .foregroundStyle(Color.textPrimary)
                    }
                }
            }
        }
    }

    private var title: String {
        "Show \(format(counts.values.reduce(0, +)))\(hasMore ? "+" : "") new"
    }

    private var severitySummary: String {
        severityOrder.compactMap { level in
            counts[level].map { "\(level.description) \(format($0))" }
        }
        .joined(separator: ", ")
    }

    private func format(_ count: Int) -> String {
        count.formatted(.number.locale(Locale(identifier: "en_US")))
    }

    private func flash() async {
        guard !counts.isEmpty else {
            return
        }

        isFlashing = true
        guard (try? await Task.sleep(for: .milliseconds(490))) != nil else {
            return
        }
        withAnimation(.easeOut(duration: 0.91)) {
            isFlashing = false
        }
    }
}

private let severityOrder: [EventLevel] = [.critical, .error, .warning, .notice, .info, .debug, .trace]

private let flashColor = designColor(light: 0xD3E4FF, dark: 0x154171)

#Preview("By severity") {
    VStack(spacing: 0) {
        EventUpdatesBar(counts: [.critical: 1, .error: 2, .warning: 1, .info: 8]) {}
        Spacer()
    }
    .dynamicTypeSize(.large)
}

#Preview("Overflow") {
    VStack(spacing: 0) {
        EventUpdatesBar(
            counts: [.critical: 1, .error: 3, .warning: 12, .notice: 24, .info: 186, .debug: 412, .trace: 1_038]
        ) {}
        Spacer()
    }
    .dynamicTypeSize(.large)
}
