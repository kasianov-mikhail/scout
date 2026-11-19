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

            SectionGap()

            cards

            Section(title: "Affected", bottomGap: .space16) {
                ForEach(Array(IncidentAffected.titles.enumerated()), id: \.offset) { item in
                    affectedRow(title: item.element, delay: 0.16 + Double(item.offset) * 0.08)
                        .overlay(alignment: .bottom) {
                            if item.offset < IncidentAffected.titles.count - 1 {
                                Separator()
                            }
                        }
                }
            }

            Section(title: "Stack Trace", note: kind.stackCaption, bottomGap: 0) {
                frames
            }

            Section(title: "Occurrences") {
                ForEach(0..<4, id: \.self) { index in
                    occurrenceRow(index: index)
                        .overlay(alignment: .bottom) {
                            if index < 3 {
                                Separator()
                            }
                        }
                }
            }
        }
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
                    .frame(height: 21)
            }

            SkeletonBar(width: 194, height: 9, delay: 0)
                .frame(height: 15)
        }
        .padding(.top, .space20)
        .padding(.horizontal, .gutter)
        .padding(.bottom, .space16)
        .overlay(alignment: .top) {
            Separator(color: kind.border)
        }
    }
}

#Preview("Crash group loading") {
    NavigationStack {
        ScrollView {
            IncidentGroupPlaceholder(kind: .crash)
        }
        .scrollIndicators(.hidden)
        .monospacedNavigationTitle(en: "NSRangeException", divider: IncidentKind.crash.border)
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
        .monospacedNavigationTitle(en: "Main Thread Blocked", divider: IncidentKind.hang.border)
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
        .monospacedNavigationTitle(en: "CPU Exception", divider: IncidentKind.resource.border)
        .toolbarBackground(IncidentKind.resource.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
