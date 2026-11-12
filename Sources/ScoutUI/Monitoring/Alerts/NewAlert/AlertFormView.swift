//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AlertFormView: View {
    @ObservedObject var provider: AlertProvider
    @StateObject private var backtest: AlertBacktestProvider
    @State private var draft: AlertDraft
    @State private var isEditingEvent = false
    @State private var message: Message?

    private let onClose: () -> Void
    private let onChangeWatch: () -> Void
    private let onSaved: () -> Void

    @Environment(\.database) private var database

    init(provider: AlertProvider, draft: AlertDraft, onClose: @escaping () -> Void, onChangeWatch: @escaping () -> Void, onSaved: @escaping () -> Void, backtest: AlertBacktestProvider? = nil) {
        self._provider = ObservedObject(wrappedValue: provider)
        self._draft = State(initialValue: draft)
        self._backtest = StateObject(wrappedValue: backtest ?? AlertBacktestProvider(metric: draft.metric))
        self.onClose = onClose
        self.onChangeWatch = onChangeWatch
        self.onSaved = onSaved
    }

    var body: some View {
        content
            .alertFormTitle(title: draft.title, isMonospaced: draft.watch.isEvent)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AlertCloseButton(action: onClose)
                }

                ToolbarItem(placement: .confirmationAction) {
                    AlertSaveButton(isEnabled: draft.isValid) {
                        save()
                    }
                }
            }
            .message($message)
            .task(id: draft.metric) {
                guard draft.isValid else {
                    backtest.result = nil
                    return
                }
                if !ProcessInfo.processInfo.isPreview {
                    backtest.result = nil
                }
                guard (try? await Task.sleep(for: .milliseconds(300))) != nil else {
                    return
                }
                backtest.metric = draft.metric
                await backtest.fetchAgain(in: database)
            }
            .sheet(isPresented: $isEditingEvent) {
                AlertEventNameView(name: draft.eventName) {
                    draft.eventName = $0
                }
            }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AlertSection(title: "Watch for") {
                    AlertWatchSummary(watch: draft.watch, change: onChangeWatch)
                }

                if draft.watch.isEvent {
                    AlertSection(title: "Event") {
                        AlertEventCard(name: draft.eventName, range: backtest.week?.usualRange, isFailed: backtest.error != nil) {
                            isEditingEvent = true
                        }
                    }
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

                Color.clear.frame(height: 24)
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
        .background(Color.surface)
    }

    private func save() {
        Task {
            do {
                try await provider.add(draft.rule)
                onSaved()
            } catch {
                message = Message(error.localizedDescription, level: .error)
            }
        }
    }
}

private struct AlertWatchSummary: View {
    let watch: AlertDraft.Watch
    let change: () -> Void

    var body: some View {
        AlertCard {
            HStack(spacing: .space8) {
                VStack(alignment: .leading, spacing: .space2) {
                    Text(verbatim: watch.templateTitle)
                        .font(.scoutRowStrong)

                    Text(verbatim: watch.summary)
                        .font(.scoutMicro)
                        .foregroundStyle(Color.textMuted)
                }

                Spacer(minLength: 0)

                Button(action: change) {
                    Text(verbatim: "Change")
                        .font(.scoutRowStrong)
                        .foregroundStyle(Color.textLink)
                }
                .buttonStyle(.plain)
            }
            .frame(height: .rowSubtitle)
            .padding(.horizontal, .space8)
        }
    }
}

extension View {
    fileprivate func alertFormTitle(title: String, isMonospaced: Bool) -> some View {
        modifier(AlertFormTitle(title: title, isMonospaced: isMonospaced))
    }
}

private struct AlertFormTitle: ViewModifier {
    let title: String
    let isMonospaced: Bool

    @ViewBuilder func body(content: Content) -> some View {
        if isMonospaced {
            content.monospacedNavigationTitle(en: title)
        } else {
            content.navigationTitle(en: title).inlineNavigationTitle()
        }
    }
}

#Preview("Form") {
    let provider = AlertProvider()
    let backtest = AlertBacktestProvider(metric: .eventCount(name: "PaymentDeclined"))
    backtest.result = .success(.sample)

    return NavigationStack {
        AlertFormView(
            provider: provider,
            draft: AlertDraft(watch: .eventSpike, eventName: "PaymentDeclined"),
            onClose: {},
            onChangeWatch: {},
            onSaved: {},
            backtest: backtest
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        AlertFormView(
            provider: AlertProvider(),
            draft: AlertDraft(watch: .eventSpike, eventName: "PaymentDeclined"),
            onClose: {},
            onChangeWatch: {},
            onSaved: {}
        )
    }
}
