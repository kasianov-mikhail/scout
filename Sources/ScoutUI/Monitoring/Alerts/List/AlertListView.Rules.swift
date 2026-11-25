//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension AlertListView {
    struct Rules: View {
        @ObservedObject var provider: AlertProvider

        @Environment(\.database) private var database
        @State private var selected: AlertStatus?

        var body: some View {
            content
                .navigationDestination(isPresented: Binding(get: { selected != nil }, set: { if !$0 { selected = nil } })) {
                    if let selected {
                        AlertDetailView(provider: provider, rule: selected.rule, status: selected)
                    }
                }
        }

        @ViewBuilder private var content: some View {
            if let error = provider.error {
                ErrorView(description: error.localizedDescription) {
                    await provider.fetchAgain(in: database)
                }
            } else if case .success(let statuses) = provider.result, statuses.isEmpty {
                ScoutUI.Placeholder(
                    text: "No alert rules",
                    systemImage: "bell.badge",
                    description: "Add a rule to get notified when a metric misbehaves."
                )
            } else {
                ScrollView {
                    if case .success(let statuses) = provider.result {
                        list(statuses)
                            .transition(.opacity)
                    } else {
                        Placeholder()
                            .transition(.opacity)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }

        private func list(_ statuses: [AlertStatus]) -> some View {
            LazyVStack(alignment: .leading, spacing: 0) {
                if provider.notificationsDenied, statuses.contains(where: \.rule.notifies) {
                    NotificationsDeniedRow()
                        .overlay(alignment: .bottom) {
                            Separator()
                        }
                        .padding(.horizontal, .gutter)
                }

                AlertListLegend()
                    .padding(.top, .space10)
                    .padding(.horizontal, .gutter)

                section(statuses.firing, title: "Firing")
                section(statuses.armed, title: "Armed")
                section(statuses.muted, title: "Muted")
            }
        }

        @ViewBuilder private func section(_ statuses: [AlertStatus], title: String) -> some View {
            if !statuses.isEmpty {
                Section(title: title) {
                    Text(verbatim: "\(statuses.count)")
                        .font(.scoutCaption)
                        .foregroundStyle(Color.textMuted)
                } content: {
                    ForEach(Array(statuses.enumerated()), id: \.element.rule) { index, status in
                        AlertRuleRow(
                            status: status,
                            isLast: index == statuses.count - 1,
                            onDelete: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    provider.remove(status.rule)
                                }
                            },
                            onMute: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    provider.mute(status.rule, until: Date().addingTimeInterval(3600))
                                }
                            },
                            onOpen: {
                                selected = status
                            }
                        )
                        .padding(.horizontal, -.gutter)
                    }
                }
            }
        }
    }
}
