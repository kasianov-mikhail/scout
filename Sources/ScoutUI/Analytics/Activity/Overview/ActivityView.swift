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
    @State private var isInked = true

    @Environment(\.database) private var database

    var body: some View {
        Group {
            switch activity.result {
            case nil:
                ActivityViewPlaceholder(range: $range, metric: metric)
                    .transition(.opacity)
            case .success(let points):
                content(points: points)
                    .transition(.opacity)
            case .failure(let error):
                ErrorView(description: Text(error.localizedDescription)) {
                    await activity.fetchAgain(in: database)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: activity.isLoading)
        .saturation(isInked ? 1 : 0)
        .animation(.easeOut(duration: 0.3), value: isInked)
        .task(id: activity.isLoading) {
            guard activity.isLoading else {
                try? await Task.sleep(for: .milliseconds(200))
                guard !Task.isCancelled else {
                    return
                }
                isInked = true
                return
            }
            isInked = false
        }
        .fetchTask([activity])
        .navigationTitle(en: "Active users")
        .inlineNavigationTitle()
    }

    private func content(points: [ActivityPoint]) -> some View {
        let series = ActivitySeries(points: points, range: range, metric: metric, now: Date())

        return InsetList {
            RangeStrip(selection: $range, ranges: ActivityRange.allCases, title: \.title)
                .padding(.top, 8)
                .padding(.trailing, -16)

            ActivityMetricTabs(series: series, selection: $metric)
                .padding(.top, 4)
                .frame(minHeight: 44)

            ActivityChart(series: series)
                .padding(.top, 16)
                .frame(minHeight: 44)

            ActivityStickiness(series: series)
                .padding(.top, 12)

            ActivityRowsHeader()

            ForEach(series.rows) { row in
                ActivityDayRow(row: row)
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
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)

            Text(verbatim: " · a monthly user comes \(series.daysPerMonthLabel) days a month")
        }
        .font(.weight450(size: 13))
        .foregroundStyle(Color(.systemGray))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}

struct ActivityRowsHeader: View {
    var body: some View {
        HStack(spacing: 0) {
            Text(verbatim: "PER DAY")
                .font(.system(size: 16, weight: .bold))

            Spacer()

            Text(verbatim: "vs day before")
                .font(.weight450(size: 13))
                .foregroundStyle(Color(.systemGray))
        }
        .padding(.top, 12)
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
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
