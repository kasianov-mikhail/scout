//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AlertDetailView: View {
    @ObservedObject var provider: AlertProvider
    @StateObject private var backtest: AlertBacktestProvider
    @State private var draft: AlertDraft
    @State private var message: Message?

    private let rule: AlertRule
    private let status: AlertStatus?

    @Environment(\.database) private var database
    @Environment(\.dismiss) private var dismiss

    init(provider: AlertProvider, rule: AlertRule, status: AlertStatus? = nil, backtest: AlertBacktestProvider? = nil) {
        self._provider = ObservedObject(wrappedValue: provider)
        self._draft = State(initialValue: AlertDraft(rule: rule))
        self._backtest = StateObject(wrappedValue: backtest ?? AlertBacktestProvider(metric: rule.metric))
        self.rule = rule
        self.status = status
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AlertSection(title: "Now") {
                    AlertNowCard(status: status, metric: rule.metric)
                }

                if draft.watch.hasThreshold {
                    AlertSection(title: draft.thresholdTitle) {
                        AlertThresholdCard(
                            value: draft.valueText,
                            unit: draft.thresholdUnit,
                            decrement: { draft.decrement() },
                            increment: { draft.increment() }
                        )
                    }
                }

                AlertSection(title: "Sensitivity") {
                    AlertSensitivityCard(watch: draft.watch, sensitivity: $draft.sensitivity, countIsBelow: draft.countIsBelow)
                }

                Text(verbatim: draft.hint)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
                    .padding(.top, .space4)

                AlertSection(title: "Last week") {
                    AlertWeekCard(week: backtest.week, draft: draft, isFailed: backtest.error != nil)

                    if let error = backtest.error {
                        ErrorRow(description: error.localizedDescription) {
                            await backtest.fetchAgain(in: database)
                        }
                        .padding(.top, .space8)
                    }
                }

                AlertSection(title: "Notify") {
                    AlertNotifyCard(notifies: $draft.notifies)
                }

                if provider.notificationsDenied, draft.notifies {
                    NotificationsDeniedRow()
                        .padding(.top, .space8)
                }

                AlertFooter()

                AlertActionButton(title: status?.isMuted == true ? "Unmute" : "Mute for 1 Hour", color: .textLink) {
                    mute()
                }
                .padding(.top, .space18)

                AlertActionButton(title: "Delete Alert", color: .textDanger) {
                    delete()
                }
                .padding(.top, .space8)

                Color.clear.frame(height: 24)
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
        .background(Color.surface)
        .navigationTitle(en: rule.metric.title)
        .inlineNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                AlertSaveButton(isEnabled: draft.isValid) {
                    save()
                }
            }
        }
        .message($message)
        .task {
            backtest.metric = rule.metric
            await backtest.fetchAgain(in: database)
        }
    }

    private func save() {
        Task {
            do {
                try await provider.update(rule: rule, updated: draft.rule)
                await provider.fetchLatest(in: database)
                dismiss()
            } catch {
                message = Message(error.localizedDescription, level: .error)
            }
        }
    }

    private func mute() {
        if status?.isMuted == true {
            do {
                try provider.unmute(rule)
            } catch {
                message = Message(error.localizedDescription, level: .error)
                return
            }
        } else {
            provider.mute(rule, until: Date().addingTimeInterval(3600))
        }

        Task {
            await provider.fetchLatest(in: database)
            dismiss()
        }
    }

    private func delete() {
        provider.remove(rule)
        Task {
            await provider.fetchLatest(in: database)
            dismiss()
        }
    }
}
