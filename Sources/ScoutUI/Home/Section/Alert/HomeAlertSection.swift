//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeAlertSection: View {
    private enum Destination: Hashable {
        case alerts
    }

    let history: AlertHistory
    let alerts: AlertProvider

    @Binding private var path: NavigationPath

    init(history: AlertHistory, alerts: AlertProvider, path: Binding<NavigationPath>) {
        self.history = history
        self.alerts = alerts
        self._path = path
    }

    var body: some View {
        Button {
            path.append(Destination.alerts)
        } label: {
            if history.isEmpty {
                Empty(rulesLabel: history.rulesLabel)
            } else {
                content(history: history)
            }
        }
        .buttonStyle(.solid)
        .navigationDestination(for: Destination.self) { _ in
            AlertListView(provider: alerts)
        }
        .padding(.horizontal, .gutter)
    }

    private func content(history: AlertHistory) -> some View {
        VStack(alignment: .leading, spacing: .space6) {
            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: "ALERTS")
                    .font(.scoutCaptionStrong)

                Spacer()

                if history.firing > 0 {
                    Text(verbatim: "\(history.firing) firing")
                        .font(.scoutCaptionStrong)
                        .foregroundStyle(Color.textDanger)
                }
            }

            AlertHealthStrip(buckets: history.buckets)
                .padding(.top, .space4)

            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: history.summary)
                    .lineLimit(1)

                Spacer()

                Text(verbatim: history.rulesLabel)
            }
            .font(.scoutCaption)
            .foregroundStyle(Color.textMuted)
            .padding(.top, .space2)
        }
        .padding(.top, .space12)
        .padding(.bottom, .space16)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var path = NavigationPath()

    NavigationStack(path: $path) {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeAlertSection(history: .sample, alerts: AlertProvider(.success(AlertStatus.samples)), path: $path)
                HomeAlertSection.Placeholder()
            }
        }
        .scrollIndicators(.hidden)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Summary · 40") {
    @Previewable @State var path = NavigationPath()

    NavigationStack(path: $path) {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeAlertSection(history: AlertHistory(buckets: AlertHistory.sample.buckets, rule: "Crash-free sessions", firing: 2, armed: 31, muted: 7, total: 40), alerts: AlertProvider(.success(AlertStatus.samples)), path: $path)
            }
        }
        .scrollIndicators(.hidden)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Summary · firing") {
    @Previewable @State var path = NavigationPath()

    NavigationStack(path: $path) {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeAlertSection(history: .sample, alerts: AlertProvider(.success(AlertStatus.samples)), path: $path)
            }
        }
        .scrollIndicators(.hidden)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Summary · many") {
    @Previewable @State var path = NavigationPath()

    NavigationStack(path: $path) {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeAlertSection(history: AlertHistory(buckets: AlertHistory.sample.buckets, rule: "Crash-free sessions", firing: 3, armed: 2, muted: 1, total: 6), alerts: AlertProvider(.success(AlertStatus.samples)), path: $path)
            }
        }
        .scrollIndicators(.hidden)
    }
}
