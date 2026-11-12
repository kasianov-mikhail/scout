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
                    .overlay(alignment: .bottom) {
                        if index < AlertDraft.Watch.allCases.count - 1 {
                            AlertDivider()
                        }
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
        HStack(spacing: .space8) {
            VStack(alignment: .leading, spacing: .space2) {
                Text(verbatim: watch.title)
                    .font(isSelected ? .scoutRowStrong : .scoutRow)

                Text(verbatim: watch.detail)
                    .font(.scoutMicro)
                    .foregroundStyle(isSelected ? Color.textLink.opacity(0.75) : Color.textMuted)
            }

            Spacer(minLength: 0)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.scoutLabelCaps)
            }
        }
        .foregroundStyle(isSelected ? Color.fillAccent : Color.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: .rowSubtitle)
        .padding(.horizontal, .space8)
        .background(isSelected ? Color.surfaceSelected : Color.clear)
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
