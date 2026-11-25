//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeActivitySection: View {
    private static let zoomID = "activity"

    let users: ActiveUsers
    let activity: ActivityProvider
    let zoom: Namespace.ID

    @Binding private var path: NavigationPath

    @State private var selected = HomeActivitySelection.dau

    init(users: ActiveUsers, activity: ActivityProvider, zoom: Namespace.ID, path: Binding<NavigationPath>) {
        self.users = users
        self.activity = activity
        self.zoom = zoom
        self._path = path
    }

    var body: some View {
        section.navigationDestination(for: HomeActivitySelection.self) { destination in
            Group {
                switch destination {
                case .dau:
                    ActivityView(activity: activity)
                case .sessions:
                    SessionsView()
                case .devices:
                    DevicesView()
                }
            }
            .zoomTransition(Self.zoomID, in: zoom)
        }
    }

    private var section: some View {
        Group {
            if users.isEmpty {
                Empty(start: users.start, end: users.end) {
                    path.append(HomeActivitySelection.dau)
                }
            } else {
                content(users: users)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(users.isEmpty ? HomeActivitySelection.dau : selected)
        }
        .zoomSource(Self.zoomID, in: zoom)
    }

    private func content(users: ActiveUsers) -> some View {
        Section(title: "Activity", bottomGap: .space10) {
            HomeSectionExpandButton {
                path.append(selected)
            }
            .accessibilityLabel(Text(verbatim: selected.showAllLabel))
        } content: {
            ReadoutTabStrip(
                values: users.metrics,
                isSelected: { $0.kind == selected },
                isLoading: false,
                spacing: 0,
                onSelect: { selected = $0.kind },
                indicator: { metric in
                    Rectangle()
                        .fill(metric.kind.accent)
                        .frame(height: 2)
                        .padding(.trailing, metric.kind == users.metrics.last?.kind ? 0 : .space12)
                }
            ) { metric, isActive in
                ActiveUserMetricView(metric: metric, isActive: isActive)
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
        .foregroundStyle(Color.textMuted)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @Namespace var zoom
    @Previewable @State var path = NavigationPath()

    NavigationStack(path: $path) {
        ScrollView {
            HomeActivitySection(
                users: .sample,
                activity: ActivityProvider(.success(ActivityPoint.samples)),
                zoom: zoom,
                path: $path
            )
        }
        .scrollIndicators(.hidden)
    }
}
