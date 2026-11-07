//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeActiveUsersSection: View {
    let users: ActiveUsers
    let onShowAll: (ActiveUsers.Kind) -> Void

    @State private var selected: ActiveUsers.Kind = .dau

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(title: "Active Users") {
                Button {
                    onShowAll(selected)
                } label: {
                    Image(systemName: "arrow.up.right.and.arrow.down.left")
                        .font(.system(size: 20))
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
                ActiveUsersChart(metric: metric, start: users.start, end: users.end)
                    .padding(.top, 14)
            }

            stickiness
                .padding(.top, 10)
                .padding(.bottom, 6)
        }
        .listRowSeparator(.hidden)
    }

    private var stickiness: some View {
        HStack(spacing: 0) {
            Text(verbatim: "Stickiness ")

            Text(verbatim: users.stickinessLabel)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text(verbatim: " · \(users.sessionsPerUserLabel) sessions per user")
        }
        .font(.footnote)
        .foregroundStyle(Color(.systemGray))
    }
}

private struct ActiveUserMetricView: View {
    let metric: ActiveUsersMetric
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: metric.kind.title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(isSelected ? Color.primary : Color(.systemGray))

            Text(verbatim: metric.valueLabel)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(isSelected ? Color.primary : Color.inactiveValue)
                .frame(height: 34, alignment: .leading)

            Text(verbatim: metric.deltaLabel)
                .font(.footnote)
                .foregroundStyle(metric.delta >= 0 ? Color.green : Color.red)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            if isSelected {
                Rectangle()
                    .fill(.green)
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
        }
    }
}
