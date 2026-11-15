//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ActivityView: View {
    @ObservedObject var activity: ActivityProvider

    @State private var range = ActivityRange.month
    @State private var metric = ActivityPeriod.daily

    @Environment(\.database) private var database

    var body: some View {
        Group {
            if let error = activity.error {
                ErrorView(description: Text(error.localizedDescription)) {
                    await activity.fetchAgain(in: database)
                }
            } else {
                ScrollView {
                    if case .success(let points) = activity.result {
                        content(points: points)
                            .transition(.opacity)
                    } else {
                        ActivityViewPlaceholder(range: $range)
                            .transition(.opacity)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .animation(.easeOut(duration: 0.2), value: activity.isLoading)
        .loadingInk(isLoading: activity.isLoading)
        .fetchTask([activity])
        .navigationTitle(en: "Active users")
        .inlineNavigationTitle()
    }

    private func content(points: [ActivityPoint]) -> some View {
        let series = ActivitySeries(points: points, range: range, metric: metric, now: Date())

        return LazyVStack(alignment: .leading, spacing: 0) {
            RangeStrip(selection: $range, ranges: ActivityRange.allCases, title: \.title)
                .padding(.top, .space8)
                .padding(.leading, .gutter)

            ActivityMetricTabs(series: series, selection: $metric)
                .padding(.top, .space4)
                .padding(.horizontal, .gutter)

            ActivityChart(series: series)
                .padding(.top, .space16)
                .padding(.horizontal, .gutter)

            ActivityStickiness(series: series)
                .padding(.top, .space12)
                .padding(.horizontal, .gutter)

            Section(title: "Per day", bottomGap: 0) {
                Text(verbatim: "vs day before")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            } content: {
                ForEach(series.rows) { row in
                    ActivityDayRow(row: row)
                }
            }
        }
    }
}

private struct ActivityStickiness: View {
    let series: ActivitySeries

    var body: some View {
        HStack(spacing: 0) {
            Text(verbatim: "Stickiness ")

            Text(verbatim: series.stickinessLabel)
                .font(.scoutCaptionStrong)
                .foregroundStyle(Color.textPrimary)

            Text(verbatim: " · a monthly user comes \(series.daysPerMonthLabel) days a month")
        }
        .font(.scoutCaption)
        .foregroundStyle(Color.textMuted)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, .space16)
    }
}

#Preview("Activity") {
    NavigationStack {
        ActivityView(activity: ActivityProvider(.success(ActivityPoint.samples)))
    }
}

#Preview("Loading") {
    NavigationStack {
        ActivityView(activity: ActivityProvider())
    }
}
