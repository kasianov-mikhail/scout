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
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: "ALERTS")
                    .font(.footnote.weight(.semibold))

                Spacer()

                if history.firing > 0 {
                    Text(verbatim: "\(history.firing) firing")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.red)
                }
            }

            AlertHealthStrip(buckets: history.buckets)
                .padding(.top, 4)

            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: history.summary)

                Spacer()

                Text(verbatim: history.rulesLabel)
            }
            .font(.book(size: 13))
            .foregroundStyle(Color(.systemGray))
            .padding(.top, 2)
        }
        .padding(.top, 12)
        .padding(.bottom, 14)
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
            .padding(.horizontal, 16)
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
            .padding(.horizontal, 16)
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
            .padding(.horizontal, 16)
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
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
    }
}
