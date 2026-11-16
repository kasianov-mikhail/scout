//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct IncidentSummaryView<Element: Incident, Row: View>: View {
    let summary: IncidentSummary
    let records: [Element]
    @ViewBuilder let row: (Element) -> Row

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            message

            SectionGap()

            cards

            if !summary.affected.isEmpty {
                Section(title: "Affected") {
                    ForEach(Array(summary.affected.enumerated()), id: \.element.id) { index, affected in
                        IncidentAffectedRow(affected: affected)
                            .overlay(alignment: .bottom) {
                                if index < summary.affected.count - 1 {
                                    Separator()
                                }
                            }
                    }
                }
            }

            if !summary.frames.isEmpty {
                Section(title: "Stack Trace", note: summary.stackCaption, bottomGap: 0) {
                    frames
                }
            }

            Section(title: "Occurrences", showsSeparator: !records.isEmpty) {
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
    }

    private var message: some View {
        VStack(alignment: .leading, spacing: .space6) {
            Text(verbatim: summary.message)
                .font(.scoutRowMono)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(verbatim: summary.meta)
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)
        }
        .padding(.top, .space20)
        .padding(.horizontal, .gutter)
        .padding(.bottom, .space16)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(summary.kind.border)
                .frame(height: 0.5)
        }
    }

    private var cards: some View {
        HStack(alignment: .top, spacing: .space24) {
            ForEach(summary.cards) { card in
                IncidentSummaryCardView(card: card, kind: summary.kind)
            }
        }
        .padding(.top, .space20)
        .padding(.bottom, .space18)
        .padding(.horizontal, .gutter)
    }

    private var frames: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(summary.frames) { frame in
                IncidentSummaryFrameRow(frame: frame)
            }
        }
        .padding(.vertical, .space16)
    }
}

private struct IncidentSummaryFrameRow: View {
    let frame: IncidentStackFrame

    var body: some View {
        HStack(spacing: .space6) {
            Text(verbatim: frame.index)
                .frame(width: 18, alignment: .leading)

            Text(verbatim: frame.image ?? "")
                .frame(width: 128, alignment: .leading)

            Text(verbatim: frame.symbol)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(frame.isApp ? .scoutCodeStrong : .scoutCode)
        .foregroundStyle(frame.isApp ? Color.textPrimary : Color.fillLevel)
        .lineLimit(1)
        .frame(height: .codeStep)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
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
                    HStack(spacing: .space8) {
                        Text(verbatim: crash.date?.relativeString ?? "")
                            .font(.scoutRow)

                        Spacer()

                        if let label = IncidentBreakdown.sample.occurrenceLabel(record: crash) {
                            Text(verbatim: label)
                                .font(.scoutCaption)
                                .foregroundStyle(Color.textMuted)
                                .lineLimit(1)
                        }
                    }
                    .lineLimit(1)
                    .frame(height: .rowRegular)
                }
            )
        }
        .scrollIndicators(.hidden)
        .monospacedNavigationTitle(en: "NSRangeException", divider: IncidentKind.crash.border)
        .toolbarBackground(IncidentKind.crash.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    .environmentObject(Tint())
}
