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
                    .font(.weight450(size: 13))
                    .foregroundStyle(Color(.systemGray))
                    .padding(.top, 4)

                AlertSection(title: "Last week") {
                    AlertWeekCard(week: backtest.week, draft: draft, isFailed: backtest.error != nil)

                    if let error = backtest.error {
                        ErrorRow(description: error.localizedDescription) {
                            await backtest.fetchAgain(in: database)
                        }
                        .padding(.top, 8)
                    }
                }

                AlertSection(title: "Notify") {
                    AlertNotifyCard(notifies: $draft.notifies)
                }

                if provider.notificationsDenied, draft.notifies {
                    NotificationsDeniedRow()
                        .padding(.top, 8)
                }

                AlertFooter()

                AlertActionButton(title: status?.isMuted == true ? "Unmute" : "Mute for 1 Hour", color: .blue) {
                    mute()
                }
                .padding(.top, 18)

                AlertActionButton(title: "Delete Alert", color: .red) {
                    delete()
                }
                .padding(.top, 8)

                Color.clear.frame(height: 24)
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemBackground))
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
                await provider.fetchAgain(in: database)
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
            await provider.fetchAgain(in: database)
            dismiss()
        }
    }

    private func delete() {
        provider.remove(rule)
        Task {
            await provider.fetchAgain(in: database)
            dismiss()
        }
    }
}

private struct AlertActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.separator, lineWidth: 0.5)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct AlertNowCard: View {
    let status: AlertStatus?
    let metric: AlertMetric

    var body: some View {
        AlertCard {
            VStack(spacing: 0) {
                value
                AlertDivider()
                stats
            }
        }
        .animation(.easeOut(duration: 0.2), value: status)
    }

    private var value: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            if let text = valueText {
                Text(verbatim: text)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(status?.isFiring == true ? Color.red : Color.primary)
                    .monospacedDigit()
            } else {
                SkeletonBar(width: 74, height: 16, delay: 0)
            }

            Text(verbatim: " \(unit)")
                .font(.weight450(size: 13))
                .foregroundStyle(Color(.systemGray))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stats: some View {
        HStack(spacing: 0) {
            stat(
                title: "Alerting since",
                text: alertingSince,
                color: status?.isFiring == true ? Color.red : Color.primary,
                showsDivider: true
            )
            stat(title: "Notified", text: alertingSince, color: Color.primary, showsDivider: false)
        }
    }

    private func stat(title: String, text: String?, color: Color, showsDivider: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: title)
                .font(.weight450(size: 11))
                .foregroundStyle(Color(.systemGray))

            if let text {
                Text(verbatim: text)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(color)
            } else {
                SkeletonBar(width: 46, height: 11, delay: 0)
            }
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            if showsDivider {
                Rectangle().fill(Color.separator).frame(width: 0.5)
            }
        }
    }

    private var valueText: String? {
        guard let status else {
            return nil
        }
        guard let value = status.reading.recent.last else {
            return "—"
        }
        return status.rule.metric.format(value)
    }

    private var unit: String {
        switch metric {
        case .crashFreeSessions:
            "crash-free sessions"
        case .eventCount:
            "events an hour"
        }
    }

    private var alertingSince: String? {
        guard let status else {
            return nil
        }
        guard case .firing(let since) = status.outcome.state else {
            return "—"
        }
        return alertTimeFormatter.string(from: since)
    }
}

private let alertTimeFormatter = DateFormatter(format: "HH:mm")

#Preview("Edit") {
    let provider = AlertProvider()
    let backtest = AlertBacktestProvider(metric: .crashFreeSessions)
    backtest.result = .success(.crashFreeSample)

    return NavigationStack {
        AlertDetailView(
            provider: provider,
            rule: AlertStatus.firingSample.rule,
            status: .firingSample,
            backtest: backtest
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        AlertDetailView(
            provider: AlertProvider(),
            rule: AlertStatus.firingSample.rule
        )
    }
}
