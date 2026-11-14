//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct RetentionView: View {
    @ObservedObject var provider: RetentionProvider

    @State private var day = RetentionDay.day7

    @Environment(\.database) private var database

    var body: some View {
        Group {
            if let error = provider.error {
                ErrorView(description: Text(error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            } else {
                ScrollView {
                    if case .success(let cohorts) = provider.result {
                        content(cohorts: cohorts)
                            .transition(.opacity)
                    } else {
                        RetentionViewPlaceholder(day: $day)
                            .transition(.opacity)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .fetchTask([provider])
        .navigationTitle(en: "Retention")
        .inlineNavigationTitle()
    }

    private func content(cohorts: [RetentionCohort]) -> some View {
        let overview = RetentionOverview(cohorts: cohorts)

        return LazyVStack(alignment: .leading, spacing: 0) {
            RetentionHero(value: overview.keptLabel(day: day), subtitle: "people kept")

            RetentionDayTabs(overview: overview, day: $day)

            RetentionSection(title: "Kept per install week", note: "day \(day.rawValue)")

            ForEach(Array(overview.weeks.enumerated()), id: \.element.id) { index, cohort in
                NavigationLink {
                    RetentionCohortDetailView(cohort: cohort, cohorts: cohorts)
                } label: {
                    RetentionWeekRow(
                        week: RetentionWeek(cohort: cohort, day: day),
                        maxInstalls: overview.maxInstalls,
                        showsDivider: index < overview.weeks.count - 1
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, .gutter)
    }
}

#Preview("Retention") {
    NavigationStack {
        RetentionView(provider: .init(.success(.samples)))
    }
}

#Preview("Loading") {
    NavigationStack {
        RetentionView(provider: .init())
    }
}
