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
            if users.isEmpty {
                HomeActiveUsersSectionEmpty(start: users.start, end: users.end) {
                    onShowAll(selected)
                }
            } else {
                content(users: users)
            }
        } else {
            HomeActiveUsersSectionPlaceholder()
        }
    }

    private func content(users: ActiveUsers) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(title: "Active Users") {
                HomeSectionExpandButton(label: "Show all active users") {
                    onShowAll(selected)
                }
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
            .background(alignment: .bottom) {
                Separator()
            }

            if let metric = users.metric(selected) {
                HomeActiveUsersChart(metric: metric, start: users.start, end: users.end)
                    .padding(.top, .space12)
            }

            footer(users: users)
                .padding(.top, .space10)
                .padding(.bottom, .space6)
        }
    }

    private func footer(users: ActiveUsers) -> some View {
        HStack(spacing: 0) {
            switch selected {
            case .dau:
                Text(verbatim: "Stickiness ")

                Text(verbatim: users.stickinessLabel)
                    .font(.scoutCaptionStrong)
                    .foregroundStyle(Color.textPrimary)

                Text(verbatim: " · \(users.sessionsPerUserLabel) sessions per user")
            case .sessions:
                if let median = users.medianSessionLabel {
                    Text(verbatim: "Median ")

                    Text(verbatim: median)
                        .font(.scoutCaptionStrong)
                        .foregroundStyle(Color.textPrimary)

                    Text(verbatim: " · \(users.sessionsPerUserLabel) sessions per user")
                } else {
                    Text(verbatim: "\(users.sessionsPerUserLabel) sessions per user")
                }
            case .devices:
                if users.newDevicesToday {
                    Text(verbatim: "First seen today · ")
                }

                Text(verbatim: users.devicesThisWeekLabel)
                    .font(.scoutCaptionStrong)
                    .foregroundStyle(Color.textPrimary)

                Text(verbatim: " this week")
            }
        }
        .font(.scoutCaption)
        .foregroundStyle(Color.homeCaption)
    }
}

private struct ActiveUserMetricView: View {
    let metric: ActiveUsersMetric
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: metric.kind.title.uppercased())
                .font(.scoutCaptionStrong)
                .foregroundStyle(isSelected ? Color.textPrimary : Color.homeCaption)

            Text(verbatim: metric.valueLabel)
                .font(.scoutNumberL)
                .foregroundStyle(isSelected ? Color.textPrimary : Color.inactiveValue)
                .frame(height: 34, alignment: .leading)

            Text(verbatim: metric.deltaLabel)
                .font(.scoutCaption)
                .foregroundStyle(metric.delta >= 0 ? Color.positive : Color.fillDanger)
        }
        .padding(.vertical, .space10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            if isSelected {
                Rectangle()
                    .fill(metric.kind.accent)
                    .frame(height: 2)
                    .padding(.trailing, .space12)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeActiveUsersSection(users: .sample) { _ in }
                HomeActiveUsersSection(users: nil) { _ in }
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Active · devices") {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeActiveUsersSection(users: .sample, selected: .devices) { _ in }
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Active · sessions") {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeActiveUsersSection(users: .sample, selected: .sessions) { _ in }
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}
