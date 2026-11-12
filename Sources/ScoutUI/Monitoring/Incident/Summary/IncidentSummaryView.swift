//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct IncidentSummaryView<Element: Incident, Row: View, Destination: View>: View {
    let summary: IncidentSummary
    let records: [Element]
    @ViewBuilder let row: (Element) -> Row
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        InsetList {
            message
                .padding(.horizontal, -16)

            cards

            if !summary.affected.isEmpty {
                Header(title: "Affected")
                    .overlay(alignment: .bottom) {
                        Separator()
                    }

                ForEach(summary.affected) { affected in
                    IncidentAffectedRow(affected: affected)
                        .overlay(alignment: .bottom) {
                            Separator()
                        }
                }
            }

            if !summary.frames.isEmpty {
                Header(title: "Stack Trace") {
                    Text(verbatim: summary.stackCaption)
                        .font(.weight450(size: 13))
                        .foregroundStyle(Color(.systemGray))
                }
                .overlay(alignment: .bottom) {
                    Separator()
                }

                frames
            }

            Header(title: "Occurrences") {
                NavigationLink {
                    destination()
                } label: {
                    Image(systemName: "arrow.up.right.and.arrow.down.left")
                        .font(.weight450(size: 20))
                        .frame(width: 44, height: 44)
                        .padding(.trailing, -12)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
                .accessibilityLabel(Text(verbatim: "Show all occurrences"))
            }
            .overlay(alignment: .bottom) {
                if !records.isEmpty {
                    Separator()
                }
            }

            ForEach(Array(records.prefix(4).enumerated()), id: \.element.id) { index, record in
                row(record)
                    .overlay(alignment: .bottom) {
                        if index < min(records.count, 4) - 1 {
                            Separator()
                        }
                    }
            }
        }
    }

    private var message: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: summary.message)
                .font(.weight450(size: 15, design: .monospaced))
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(verbatim: summary.meta)
                .font(.weight450(size: 13))
                .foregroundStyle(Color(.systemGray))
        }
        .padding(.top, 20)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(summary.kind.border)
                .frame(height: 0.5)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
                .padding(.horizontal, 16)
        }
    }

    private var cards: some View {
        HStack(alignment: .top, spacing: 24) {
            ForEach(summary.cards) { card in
                IncidentSummaryCardView(card: card, kind: summary.kind)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private var frames: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(summary.frames) { frame in
                IncidentSummaryFrameRow(frame: frame)
            }
        }
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}

private struct IncidentSummaryCardView: View {
    let card: IncidentSummaryCard
    let kind: IncidentKind

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: card.title)
                .font(.weight450(size: 14))
                .foregroundStyle(Color(.systemGray))

            HStack(alignment: .top) {
                Text(verbatim: card.value)
                    .font(.system(size: 24, weight: .bold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer(minLength: 8)

                if let change = card.change {
                    Text(verbatim: change)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(kind.textColor)
                        .lineLimit(1)
                        .padding(.top, 2)
                }
            }
            .frame(height: 28)

            bars
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var bars: some View {
        let maximum = card.bars.max() ?? 0

        return HStack(alignment: .bottom, spacing: 4) {
            ForEach(card.bars.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(kind.color)
                    .opacity(index == card.bars.count - 1 ? 1 : 0.3)
                    .frame(maxWidth: .infinity)
                    .frame(height: barHeight(card.bars[index], maximum: maximum))
            }
        }
        .frame(height: 52, alignment: .bottom)
    }

    private func barHeight(_ value: Double, maximum: Double) -> CGFloat {
        guard maximum > 0 else {
            return 3
        }
        return 3 + CGFloat(value / maximum) * 49
    }
}

private struct IncidentAffectedRow: View {
    let affected: IncidentAffected

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(verbatim: affected.title)
                    .font(.weight450(size: 15))

                Spacer()

                Text(verbatim: "\(affected.total)")
                    .font(.weight450(size: 15))
                    .monospacedDigit()
                    .foregroundStyle(Color(.systemGray))
            }

            bar

            ViewThatFits(in: .horizontal) {
                legend(visible: affected.segments.count)
                legend(visible: affected.segments.count - 1)
                legend(visible: affected.segments.count - 2)
                legend(visible: affected.segments.count - 3)
                legend(visible: affected.segments.count - 4)
            }
        }
        .padding(.vertical, 16)
    }

    private func legend(visible count: Int) -> some View {
        let visible = min(max(count, 1), affected.segments.count)

        return HStack(spacing: 14) {
            ForEach(affected.segments.prefix(visible)) { segment in
                HStack(spacing: 5) {
                    Circle()
                        .fill(segment.color)
                        .frame(width: 7, height: 7)

                    Text(verbatim: label(segment: segment))
                        .lineLimit(1)
                }
            }

            if affected.segments.count > visible {
                Text(verbatim: "+\(affected.segments.count - visible)")
            }
        }
        .font(.weight450(size: 12))
        .foregroundStyle(Color(.systemGray))
        .fixedSize(horizontal: true, vertical: false)
    }

    private var bar: some View {
        GeometryReader { proxy in
            let gaps = CGFloat(max(affected.segments.count - 1, 0)) * 2
            let width = max(proxy.size.width - gaps, 0)

            HStack(spacing: 2) {
                ForEach(affected.segments) { segment in
                    Rectangle()
                        .fill(segment.color)
                        .frame(width: width * share(segment: segment))
                }
            }
        }
        .frame(height: 8)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func label(segment: Segment) -> String {
        affected.usesDeviceNames ? DeviceModel(identifier: segment.label).name : segment.label
    }

    private func share(segment: Segment) -> CGFloat {
        guard affected.total > 0 else {
            return 0
        }
        return CGFloat(segment.count) / CGFloat(affected.total)
    }
}

private struct IncidentSummaryFrameRow: View {
    let frame: IncidentStackFrame

    var body: some View {
        HStack(spacing: 6) {
            Text(verbatim: frame.index)
                .frame(width: 18, alignment: .leading)

            Text(verbatim: frame.image ?? "")
                .frame(width: 128, alignment: .leading)

            Text(verbatim: frame.symbol)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(frame.isApp ? .system(size: 12, weight: .semibold, design: .monospaced) : .weight450(size: 12, design: .monospaced))
        .foregroundStyle(frame.isApp ? Color.primary : Color(.systemGray))
        .lineLimit(1)
        .frame(height: 16)
    }
}

#Preview {
    NavigationStack {
        IncidentSummaryView(
            summary: IncidentSummary(
                kind: .crash,
                label: "Crash",
                message: Crash.sample.reason,
                group: IncidentGroup(records: [Crash].samples),
                breakdown: .sample,
                cards: [
                    .occurrences(records: [Crash].samples, value: "12"),
                    .devices(records: [Crash].samples, value: "8"),
                ],
                stack: Crash.sample.stackTrace
            ),
            records: [Crash].samples,
            row: { crash in
                Text(verbatim: crash.name)
            },
            destination: {
                Text(verbatim: "All occurrences")
            }
        )
        .monospacedNavigationTitle(en: "NSRangeException")
        .toolbarBackground(IncidentKind.crash.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    .environmentObject(Tint())
}
