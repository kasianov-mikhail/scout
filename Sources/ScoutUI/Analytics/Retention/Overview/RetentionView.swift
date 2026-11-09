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
            switch provider.result {
            case nil:
                RetentionViewPlaceholder(day: $day)
                    .transition(.opacity)
            case .success(let cohorts):
                content(cohorts: cohorts)
                    .transition(.opacity)
            case .failure(let error):
                ErrorView(description: Text(error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .fetchTask([provider])
        .navigationTitle(en: "Retention")
        .inlineNavigationTitle()
    }

    private func content(cohorts: [RetentionCohort]) -> some View {
        let overview = RetentionOverview(cohorts: cohorts)

        return InsetList {
            RetentionHero(value: overview.keptLabel(day: day), subtitle: "people kept")
                .frame(minHeight: 44)

            RetentionDayTabs(overview: overview, day: $day)
                .frame(minHeight: 44)

            RetentionSection(title: "Kept per install week", note: "day \(day.rawValue)")

            ForEach(Array(overview.weeks.enumerated()), id: \.element.id) { index, cohort in
                Row(minHeight: 40) {
                    RetentionWeekRow(
                        week: RetentionWeek(cohort: cohort, day: day),
                        maxInstalls: overview.maxInstalls,
                        showsDivider: index < overview.weeks.count - 1
                    )
                } destination: {
                    RetentionCohortDetailView(cohort: cohort, cohorts: cohorts)
                }
            }
        }
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
