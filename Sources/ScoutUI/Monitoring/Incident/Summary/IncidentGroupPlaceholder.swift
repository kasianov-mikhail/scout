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
        ScrollView {
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
                        .font(.weight450(size: 13))
                        .foregroundStyle(Color(.systemGray))
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
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var message: some View {
        VStack(alignment: .leading, spacing: 6) {
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
        .padding(.top, 20)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(kind.border)
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
            ForEach(Array(cardTitles.enumerated()), id: \.offset) { item in
                card(title: item.element)
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

    private func card(title: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: title)
                .font(.weight450(size: 14))
                .foregroundStyle(Color(.systemGray))

            HStack {
                SkeletonBar(width: 46, height: 20, delay: 0.08)

                Spacer()

                SkeletonBar(width: 28, height: 10, delay: 0.08)
            }
            .frame(height: 28)

            SkeletonBar(height: 52, delay: 0.08, cornerRadius: 4, fill: Color(.systemGray6))
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func affectedRow(title: String, delay: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(verbatim: title)
                    .font(.weight450(size: 15))

                Spacer()

                SkeletonBar(width: 28, height: 11, delay: delay)
            }

            SkeletonBar(height: 8, delay: delay, cornerRadius: 4)

            HStack(spacing: 14) {
                SkeletonBar(width: 74, height: 9, delay: delay)
                SkeletonBar(width: 46, height: 9, delay: delay)
                SkeletonBar(width: 46, height: 9, delay: delay)
            }
        }
        .padding(.vertical, 16)
    }

    private var frames: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(0..<6, id: \.self) { index in
                let delay = 0.40 + Double(index) * 0.08

                HStack(spacing: 6) {
                    SkeletonBar(width: 8, height: 9, delay: delay)
                        .frame(width: 18, alignment: .leading)

                    SkeletonBar(width: 74, height: 9, delay: delay)
                        .frame(width: 128, alignment: .leading)

                    SkeletonBar(width: [158, 115, 141, 92, 126, 104][index % 6], height: 9, delay: delay)
                }
                .frame(height: 16)
            }
        }
        .padding(.vertical, 16)
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
        .frame(height: 44)
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
        IncidentGroupPlaceholder(kind: .crash)
            .monospacedNavigationTitle(en: "NSRangeException")
            .toolbarBackground(IncidentKind.crash.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview("Hang group loading") {
    NavigationStack {
        IncidentGroupPlaceholder(kind: .hang)
            .monospacedNavigationTitle(en: "Main Thread Blocked")
            .toolbarBackground(IncidentKind.hang.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview("Resource group loading") {
    NavigationStack {
        IncidentGroupPlaceholder(kind: .resource, resourceKind: .cpu)
            .monospacedNavigationTitle(en: "CPU Exception")
            .toolbarBackground(IncidentKind.resource.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}
