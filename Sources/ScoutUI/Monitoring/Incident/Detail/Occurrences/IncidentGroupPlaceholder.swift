//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct IncidentGroupPlaceholder: View {
    let kind: IncidentKind
    var resourceKind: ResourceKind? = nil

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            message
                .padding(.horizontal, -16)

            cards

            Header(title: "Affected")
                .overlay(alignment: .bottom) {
                    Separator()
                }

            ForEach(Array(IncidentAffected.titles.enumerated()), id: \.offset) { item in
                affectedRow(title: item.element, delay: 0.16 + Double(item.offset) * 0.08)
                    .overlay(alignment: .bottom) {
                        Separator()
                    }
            }

            Header(title: "Stack Trace") {
                Text(verbatim: kind.stackCaption)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }
            .overlay(alignment: .bottom) {
                Separator()
            }

            frames

            Header(title: "Occurrences")
                .overlay(alignment: .bottom) {
                    Separator()
                }

            ForEach(0..<4, id: \.self) { index in
                occurrenceRow(index: index)
                    .overlay(alignment: .bottom) {
                        if index < 3 {
                            Separator()
                        }
                    }
            }
        }
        .padding(.horizontal, .gutter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var message: some View {
        VStack(alignment: .leading, spacing: .space6) {
            VStack(alignment: .leading, spacing: 0) {
                SkeletonBar(height: 11, delay: 0)
                    .frame(maxWidth: .infinity)
                    .frame(height: 21)

                SkeletonBar(width: 194, height: 11, delay: 0)
                    .frame(height: 21, alignment: .leading)
            }

            SkeletonBar(width: 194, height: 9, delay: 0)
                .frame(height: 15, alignment: .leading)
        }
        .padding(.top, .space20)
        .padding(.horizontal, .gutter)
        .padding(.bottom, .space16)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(kind.border)
                .frame(height: 0.5)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
                .padding(.horizontal, .gutter)
        }
    }

    private var cards: some View {
        HStack(alignment: .top, spacing: .space24) {
            ForEach(Array(cardTitles.enumerated()), id: \.offset) { item in
                card(title: item.element)
            }
        }
        .padding(.top, .space20)
        .padding(.bottom, .space12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private func card(title: String) -> some View {
        VStack(alignment: .leading, spacing: .space4) {
            Text(verbatim: title)
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)

            HStack {
                SkeletonBar(width: 46, height: 20, delay: 0.08)

                Spacer()

                SkeletonBar(width: 28, height: 10, delay: 0.08)
            }
            .frame(height: 28)

            SkeletonBar(height: 52, delay: 0.08, cornerRadius: .radiusBadge, fill: Color.surfaceGrey)
                .padding(.top, .space4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func affectedRow(title: String, delay: Double) -> some View {
        VStack(alignment: .leading, spacing: .space6) {
            HStack {
                Text(verbatim: title)
                    .font(.scoutRow)

                Spacer()

                SkeletonBar(width: 28, height: 11, delay: delay)
            }

            SkeletonBar(height: 8, delay: delay, cornerRadius: .radiusBadge)

            HStack(spacing: .space12) {
                SkeletonBar(width: 74, height: 9, delay: delay)
                SkeletonBar(width: 46, height: 9, delay: delay)
                SkeletonBar(width: 46, height: 9, delay: delay)
            }
        }
        .frame(height: .rowSubtitle)
    }

    private var frames: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<6, id: \.self) { index in
                let delay = 0.40 + Double(index) * 0.08

                HStack(spacing: .space6) {
                    SkeletonBar(width: 8, height: 9, delay: delay)
                        .frame(width: 18, alignment: .leading)

                    SkeletonBar(width: 74, height: 9, delay: delay)
                        .frame(width: 128, alignment: .leading)

                    SkeletonBar(width: [158, 115, 141, 92, 126, 104][index % 6], height: 9, delay: delay)
                }
                .frame(height: .codeStep)
            }
        }
        .padding(.vertical, .space16)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private func occurrenceRow(index: Int) -> some View {
        let delay = 0.88 + Double(index) * 0.08

        return HStack {
            SkeletonBar(width: 74, height: 11, delay: delay)

            Spacer()

            SkeletonBar(width: 120, height: 9, delay: delay)
        }
        .frame(height: .rowRegular)
    }

    private var cardTitles: [String] {
        switch kind {
        case .crash:
            [kind.occurrencesTitle, "DEVICES"]
        case .hang:
            [kind.occurrencesTitle, "LONGEST"]
        case .resource:
            [kind.occurrencesTitle, resourceKind?.peakTitle ?? "PEAK"]
        }
    }
}

#Preview("Crash group loading") {
    NavigationStack {
        ScrollView {
            IncidentGroupPlaceholder(kind: .crash)
        }
        .scrollIndicators(.hidden)
        .monospacedNavigationTitle(en: "NSRangeException")
        .toolbarBackground(IncidentKind.crash.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview("Hang group loading") {
    NavigationStack {
        ScrollView {
            IncidentGroupPlaceholder(kind: .hang)
        }
        .scrollIndicators(.hidden)
        .monospacedNavigationTitle(en: "Main Thread Blocked")
        .toolbarBackground(IncidentKind.hang.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview("Resource group loading") {
    NavigationStack {
        ScrollView {
            IncidentGroupPlaceholder(kind: .resource, resourceKind: .cpu)
        }
        .scrollIndicators(.hidden)
        .monospacedNavigationTitle(en: "CPU Exception")
        .toolbarBackground(IncidentKind.resource.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
