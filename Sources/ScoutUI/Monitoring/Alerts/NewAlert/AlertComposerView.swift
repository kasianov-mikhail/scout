//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AlertComposerView: View {
    @ObservedObject var provider: AlertProvider
    @StateObject private var backtest: AlertBacktestProvider
    @State private var draft: AlertDraft
    @State private var isEditingEvent = false
    @State private var message: Message?

    @Environment(\.database) private var database
    @Environment(\.dismiss) private var dismiss

    init(provider: AlertProvider, draft: AlertDraft = AlertDraft(), backtest: AlertBacktestProvider? = nil) {
        self._provider = ObservedObject(wrappedValue: provider)
        self._draft = State(initialValue: draft)
        self._backtest = StateObject(wrappedValue: backtest ?? AlertBacktestProvider(metric: draft.metric))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AlertSection(title: "Watch for") {
                    AlertWatchPicker(watch: draft.watch) {
                        draft.select($0)
                    }
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

                Color.clear.frame(height: 24)
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemBackground))
        .navigationTitle(en: "New Alert")
        .inlineNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                AlertCloseButton {
                    dismiss()
                }
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

    private func save() {
        Task {
            do {
                try await provider.add(draft.rule)
                dismiss()
            } catch {
                message = Message(error.localizedDescription, level: .error)
            }
        }
    }
}

private struct AlertWatchPicker: View {
    let watch: AlertDraft.Watch
    let select: (AlertDraft.Watch) -> Void

    var body: some View {
        AlertCard {
            VStack(spacing: 0) {
                ForEach(AlertDraft.Watch.allCases.indices, id: \.self) { index in
                    let option = AlertDraft.Watch.allCases[index]

                    Button {
                        select(option)
                    } label: {
                        AlertWatchPickerRow(watch: option, isSelected: option == watch)
                    }
                    .buttonStyle(.plain)

                    if index < AlertDraft.Watch.allCases.count - 1 {
                        AlertDivider()
                    }
                }
            }
        }
    }
}

private struct AlertWatchPickerRow: View {
    let watch: AlertDraft.Watch
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: watch.title)
                    .font(isSelected ? .system(size: 15, weight: .bold) : .weight450(size: 15))

                Text(verbatim: watch.detail)
                    .font(.weight450(size: 11))
                    .foregroundStyle(isSelected ? Color.blue.opacity(0.75) : Color(.systemGray))
            }

            Spacer(minLength: 0)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))
            }
        }
        .foregroundStyle(isSelected ? Color.blue : Color.primary)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.blue.opacity(0.12) : Color.clear)
        .contentShape(Rectangle())
    }
}

#Preview("One Screen") {
    let provider = AlertProvider()
    let backtest = AlertBacktestProvider(metric: .eventCount(name: "PaymentDeclined"))
    backtest.result = .success(.sample)

    return NavigationStack {
        AlertComposerView(
            provider: provider,
            draft: AlertDraft(watch: .eventSpike, eventName: "PaymentDeclined"),
            backtest: backtest
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        AlertComposerView(
            provider: AlertProvider(),
            draft: AlertDraft(watch: .eventSpike, eventName: "PaymentDeclined")
        )
    }
}
