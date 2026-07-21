//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AlertEditorView: View {
    @ObservedObject var provider: AlertProvider

    @StateObject private var backtest = AlertBacktestProvider(metric: .crashFreeSessions)
    @State private var draft = AlertDraft()

    @Environment(\.database) private var database
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PlainList {
            Header(title: "Metric")
            metricRow

            if draft.choice == .eventCount {
                eventNameRow
            }

            Header(title: "Condition")
            PillRow(
                options: AlertDraft.Kind.allCases,
                selection: $draft.kind
            ) { $0.label }

            valueRow

            Header(title: "For at least")
            PillRow(
                options: AlertDraft.Hold.allCases,
                selection: $draft.hold
            ) { $0.label }

            Header(title: "Delivery")

            Toggle(isOn: $draft.notifies) {
                Text(verbatim: "Notify on this device")
            }
            .trailingRowSeparator()

            backtestRow
        }
        .navigationTitle(en: "New Rule")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        await provider.add(draft.rule)
                        dismiss()
                    }
                } label: {
                    Text(verbatim: "Save")
                }
                .disabled(!draft.isValid)
            }
        }
        .task(id: draft.metric) {
            guard draft.isValid else { return }
            guard (try? await Task.sleep(nanoseconds: 300_000_000)) != nil else { return }

            backtest.metric = draft.metric
            await backtest.fetchAgain(in: database)
        }
    }

    private var metricRow: some View {
        Menu {
            ForEach(AlertDraft.MetricChoice.allCases, id: \.self) { choice in
                Button {
                    draft.choice = choice
                } label: {
                    Text(verbatim: choice.label)
                }
            }
        } label: {
            HStack {
                Text(verbatim: draft.choice.label)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .trailingRowSeparator()
    }

    private var eventNameRow: some View {
        TextField(text: $draft.eventName, prompt: Text(verbatim: "Event name")) {
            Text(verbatim: "Event name")
        }
        .autocorrectionDisabled()
        .trailingRowSeparator()
    }

    private var valueRow: some View {
        HStack {
            Text(verbatim: draft.valueText)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .monospacedDigit()

            Spacer()

            Stepper {
                EmptyView()
            } onIncrement: {
                draft.increment()
            } onDecrement: {
                draft.decrement()
            }
            .labelsHidden()
        }
        .trailingRowSeparator()
    }

    @ViewBuilder private var backtestRow: some View {
        if draft.isValid, case .success(let test) = backtest.result {
            Label {
                Text(verbatim: test.summary(for: draft.rule))
            } icon: {
                Image(systemName: "clock.arrow.circlepath")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .listRowSeparator(.hidden)
            .padding(.top, 8)
        }
    }
}

private struct PillRow<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    Text(verbatim: label(option))
                        .font(.subheadline.weight(option == selection ? .semibold : .regular))
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(
                            option == selection ? Color.accentColor.opacity(0.15) : Color(.systemGray6),
                            in: Capsule()
                        )
                        .foregroundStyle(option == selection ? Color.accentColor : .primary)
                }
                .buttonStyle(.plain)
            }
        }
        .listRowSeparator(.hidden)
    }
}

#Preview {
    NavigationStack {
        AlertEditorView(provider: AlertProvider())
    }
}
