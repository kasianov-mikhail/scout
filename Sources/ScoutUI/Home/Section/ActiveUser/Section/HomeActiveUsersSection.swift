//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeActiveUsersSection: View {
    let users: ActiveUsers?
    let onShowAll: (ActiveUsers.Kind) -> Void

    @State private var selected: ActiveUsers.Kind

    init(users: ActiveUsers?, selected: ActiveUsers.Kind = .dau, onShowAll: @escaping (ActiveUsers.Kind) -> Void) {
        self.users = users
        self.onShowAll = onShowAll
        self._selected = State(initialValue: selected)
    }

    var body: some View {
        if let users {
            content(users: users)
        } else {
            HomeActiveUsersSectionPlaceholder()
        }
    }

    private func content(users: ActiveUsers) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(title: "Active Users") {
                Button {
                    onShowAll(selected)
                } label: {
                    Image(systemName: "arrow.up.right.and.arrow.down.left")
                        .font(.weight450(size: 20))
                        .frame(width: 44, height: 44)
                        .padding(.trailing, -12)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
                .accessibilityLabel(Text(verbatim: "Show all active users"))
            }

            HStack(alignment: .top, spacing: 0) {
                ForEach(users.metrics) { metric in
                    Button {
                        selected = metric.kind
                    } label: {
                        ActiveUserMetricView(metric: metric, isSelected: metric.kind == selected)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(metric.kind == selected ? .isSelected : [])
                }
            }

            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)

            if let metric = users.metric(selected) {
                HomeActiveUsersChart(metric: metric, start: users.start, end: users.end)
                    .padding(.top, 14)
            }

            footer(users: users)
                .padding(.top, 10)
                .padding(.bottom, 6)
        }
    }

    private func footer(users: ActiveUsers) -> some View {
        HStack(spacing: 0) {
            switch selected {
            case .dau:
                Text(verbatim: "Stickiness ")

                Text(verbatim: users.stickinessLabel)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(verbatim: " · \(users.sessionsPerUserLabel) sessions per user")
            case .sessions:
                if let median = users.medianSessionLabel {
                    Text(verbatim: "Median ")

                    Text(verbatim: median)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(verbatim: " · \(users.sessionsPerUserLabel) sessions per user")
                } else {
                    Text(verbatim: "\(users.sessionsPerUserLabel) sessions per user")
                }
            case .devices:
                if users.newDevicesToday {
                    Text(verbatim: "First seen today · ")
                }

                Text(verbatim: users.devicesThisWeekLabel)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(verbatim: " this week")
            }
        }
        .font(.weight450(size: 13))
        .foregroundStyle(Color(.systemGray))
        .frame(minHeight: 18, alignment: .leading)
    }
}

private struct ActiveUserMetricView: View {
    let metric: ActiveUsersMetric
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: metric.kind.title.uppercased())
                .font(.footnote.weight(.semibold))
                .foregroundStyle(isSelected ? Color.primary : Color(.systemGray))

            Text(verbatim: metric.valueLabel)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(isSelected ? Color.primary : Color.inactiveValue)
                .frame(height: 34, alignment: .leading)

            Text(verbatim: metric.deltaLabel)
                .font(.weight450(size: 13))
                .foregroundStyle(metric.delta >= 0 ? Color.positive : Color.red)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            if isSelected {
                Rectangle()
                    .fill(metric.kind.accent)
                    .frame(height: 2)
                    .padding(.trailing, 12)
            }
        }
    }
}

#Preview {
    NavigationStack {
        InsetList {
            HomeActiveUsersSection(users: .sample) { _ in }
                .frame(minHeight: 44)
            HomeActiveUsersSection(users: nil) { _ in }
                .frame(minHeight: 44)
        }
    }
}

#Preview("Active · devices") {
    NavigationStack {
        InsetList {
            HomeActiveUsersSection(users: .sample, selected: .devices) { _ in }
                .frame(minHeight: 44)
        }
    }
}

#Preview("Active · sessions") {
    NavigationStack {
        InsetList {
            HomeActiveUsersSection(users: .sample, selected: .sessions) { _ in }
                .frame(minHeight: 44)
        }
    }
}
