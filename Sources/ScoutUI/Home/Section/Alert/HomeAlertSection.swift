//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeAlertSection: View {
    let history: AlertHistory?
    let action: () -> Void

    var body: some View {
        if let history {
            Button(action: action) {
                if history.isEmpty {
                    HomeAlertSectionEmpty(rulesLabel: history.rulesLabel)
                } else {
                    content(history: history)
                }
            }
            .buttonStyle(.plain)
        } else {
            HomeAlertSectionPlaceholder()
        }
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

                Spacer()

                Text(verbatim: history.rulesLabel)
            }
            .font(.scoutCaption)
            .foregroundStyle(Color.textMuted)
            .padding(.top, .space2)
        }
        .padding(.top, .space12)
        .padding(.bottom, .space12)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeAlertSection(history: .sample) {}
                HomeAlertSection(history: nil) {}
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Summary · 40") {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeAlertSection(history: AlertHistory(buckets: AlertHistory.sample.buckets, rule: "Crash-free sessions", firing: 2, armed: 31, muted: 7, total: 40)) {}
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Summary · firing") {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeAlertSection(history: .sample) {}
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Summary · many") {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeAlertSection(history: AlertHistory(buckets: AlertHistory.sample.buckets, rule: "Crash-free sessions", firing: 3, armed: 2, muted: 1, total: 6)) {}
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}
