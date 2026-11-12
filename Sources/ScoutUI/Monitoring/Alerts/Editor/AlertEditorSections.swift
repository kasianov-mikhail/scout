//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct AlertSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(Color(.systemGray))

            content()
        }
        .padding(.top, 22)
    }
}

struct AlertCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .overlay {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.separator, lineWidth: 0.5)
            }
    }
}

struct AlertDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.separator)
            .frame(height: 0.5)
            .allowsHitTesting(false)
    }
}

struct AlertEventCard: View {
    let name: String
    let range: ClosedRange<Int>?
    let isFailed: Bool
    let change: (() -> Void)?

    var body: some View {
        AlertCard {
            if let change {
                Button(action: change) {
                    row(showsChange: true)
                }
                .buttonStyle(.plain)
            } else {
                row(showsChange: false)
            }
        }
        .animation(.easeOut(duration: 0.2), value: range)
    }

    private func row(showsChange: Bool) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: name.isEmpty ? "Choose event" : name)
                    .font(.book(size: 15, design: name.isEmpty ? .default : .monospaced))
                    .lineLimit(1)
                    .truncationMode(.middle)

                detail
            }

            Spacer(minLength: 0)

            if showsChange {
                Text(verbatim: "Change")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.blue)
            }
        }
        .frame(height: .rowSubtitle)
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
    }

    @ViewBuilder private var detail: some View {
        if name.isEmpty {
            Text(verbatim: "Tap to pick an event")
                .font(.book(size: 11))
                .foregroundStyle(Color(.systemGray))
        } else if let range {
            Text(verbatim: rangeText(range))
                .font(.book(size: 11))
                .foregroundStyle(Color(.systemGray))
        } else if isFailed {
            Text(verbatim: "—")
                .font(.book(size: 11))
                .foregroundStyle(Color(.systemGray))
        } else {
            SkeletonBar(width: 120, height: 7, delay: 0)
        }
    }

    private func rangeText(_ range: ClosedRange<Int>) -> String {
        range.lowerBound == range.upperBound
            ? "Usually \(range.lowerBound) an hour"
            : "Usually \(range.lowerBound)–\(range.upperBound) an hour"
    }
}

struct AlertEventNameView: View {
    let onSave: (String) -> Void

    @State private var name: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    init(name: String, onSave: @escaping (String) -> Void) {
        self._name = State(initialValue: name)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                TextField(text: $name, prompt: Text(verbatim: "Event name")) {
                    Text(verbatim: "Event name")
                }
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .focused($isFocused)

                Spacer()
            }
            .padding(16)
            .navigationTitle(en: "Event")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(verbatim: "Cancel")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave(name)
                        dismiss()
                    } label: {
                        Text(verbatim: "Done")
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
}

struct AlertSensitivityCard: View {
    let watch: AlertDraft.Watch
    @Binding var sensitivity: AlertDraft.Sensitivity
    let countIsBelow: Bool

    var body: some View {
        AlertCard {
            HStack(spacing: 0) {
                ForEach(AlertDraft.Sensitivity.allCases.indices, id: \.self) { index in
                    let option = AlertDraft.Sensitivity.allCases[index]

                    Button {
                        sensitivity = option
                    } label: {
                        AlertSensitivityCell(
                            title: option.title,
                            detail: watch.detail(for: option, isBelow: countIsBelow),
                            isSelected: option == sensitivity
                        )
                    }
                    .buttonStyle(.plain)
                    .overlay(alignment: .trailing) {
                        if index < AlertDraft.Sensitivity.allCases.count - 1 {
                            Rectangle().fill(Color.separator).frame(width: 0.5)
                        }
                    }
                }
            }
        }
    }
}

private struct AlertSensitivityCell: View {
    let title: String
    let detail: String
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: title)
                .font(isSelected ? .system(size: 15, weight: .bold) : .book(size: 15))
                .foregroundStyle(isSelected ? Color.blue : Color.primary)

            Text(verbatim: detail)
                .font(.book(size: 11))
                .foregroundStyle(isSelected ? Color.blue.opacity(0.75) : Color(.systemGray))
                .lineLimit(1)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.blue.opacity(0.12) : Color.clear)
        .contentShape(Rectangle())
    }
}

struct AlertThresholdCard: View {
    let value: String
    let unit: String
    let decrement: () -> Void
    let increment: () -> Void

    var body: some View {
        AlertCard {
            HStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(verbatim: value)
                        .font(.system(size: 20, weight: .bold))
                        .monospacedDigit()

                    Text(verbatim: " \(unit)")
                        .font(.book(size: 13))
                        .foregroundStyle(Color(.systemGray))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

                stepButton(symbol: "−", label: "Decrease", action: decrement)
                stepButton(symbol: "+", label: "Increase", action: increment)
            }
            .frame(height: 44)
        }
    }

    private func stepButton(symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(verbatim: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.blue)
                .frame(width: 48, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .leading) {
            Rectangle().fill(Color.separator).frame(width: 0.5)
        }
        .accessibilityLabel(Text(verbatim: label))
    }
}

struct AlertWeekCard: View {
    let week: AlertWeek?
    let draft: AlertDraft
    let isFailed: Bool

    var body: some View {
        let counts = week?.fireCounts(for: draft)
        let breaches = week?.breachGrid(for: draft.rule)

        AlertCard {
            VStack(spacing: 0) {
                summary(counts)
                    .overlay(alignment: .bottom) {
                        AlertDivider()
                    }
                countsRow(counts)
                    .overlay(alignment: .bottom) {
                        AlertDivider()
                    }
                grid(breaches)
            }
        }
        .animation(.easeOut(duration: 0.2), value: week)
    }

    private var dates: [Date] {
        if let dates = week?.days.map(\.date) {
            return dates
        }
        return AlertWeek.weekDays(ending: Date().startOfDay)
    }

    private func summary(_ counts: [AlertDraft.Sensitivity: Int]?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            if let count = counts?[draft.sensitivity] {
                Text(verbatim: "\(count)")
                    .font(.system(size: 20, weight: .bold))
                    .monospacedDigit()
            } else if isFailed {
                Text(verbatim: "—")
                    .font(.system(size: 20, weight: .bold))
            } else {
                SkeletonBar(width: 28, height: 16, delay: 0)
            }

            Text(verbatim: " alerts with \(draft.sensitivity.title)")
                .font(.book(size: 13))
                .foregroundStyle(Color(.systemGray))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func countsRow(_ counts: [AlertDraft.Sensitivity: Int]?) -> some View {
        HStack(spacing: 0) {
            ForEach(AlertDraft.Sensitivity.allCases.indices, id: \.self) { index in
                let sensitivity = AlertDraft.Sensitivity.allCases[index]

                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: sensitivity.title)
                        .font(.book(size: 11))
                        .foregroundStyle(Color(.systemGray))

                    if let count = counts?[sensitivity] {
                        Text(verbatim: "\(count)")
                            .font(.system(size: 15, weight: .semibold))
                            .monospacedDigit()
                    } else if isFailed {
                        Text(verbatim: "—")
                            .font(.system(size: 15, weight: .semibold))
                    } else {
                        SkeletonBar(width: 28, height: 11, delay: 0)
                    }
                }
                .padding(.vertical, 9)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .trailing) {
                    if index < AlertDraft.Sensitivity.allCases.count - 1 {
                        Rectangle().fill(Color.separator).frame(width: 0.5)
                    }
                }
            }
        }
    }

    private func grid(_ breaches: [[Bool]]?) -> some View {
        VStack(spacing: 3) {
            ForEach(dates.indices, id: \.self) { day in
                HStack(spacing: 2) {
                    Text(verbatim: alertWeekdayFormatter.string(from: dates[day]))
                        .font(.book(size: 10, design: .monospaced))
                        .foregroundStyle(Color(.systemGray))
                        .frame(width: 34, alignment: .leading)

                    HStack(spacing: 2) {
                        ForEach(0..<24, id: \.self) { hour in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cellColor(breaches, day: day, hour: hour))
                                .frame(height: 12)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(height: 15)
            }

            HStack(spacing: 0) {
                Color.clear.frame(width: 34, height: 1)

                HStack(spacing: 0) {
                    Text(verbatim: "00")
                    Spacer()
                    Text(verbatim: "06")
                    Spacer()
                    Text(verbatim: "12")
                    Spacer()
                    Text(verbatim: "18")
                    Spacer()
                    Text(verbatim: "24")
                }
                .font(.book(size: 10, design: .monospaced))
                .foregroundStyle(Color(.systemGray))
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
    }

    private func cellColor(_ breaches: [[Bool]]?, day: Int, hour: Int) -> Color {
        guard let breaches else {
            return Color(.systemGray6)
        }
        guard breaches.indices.contains(day) else {
            return Color(.systemGray6)
        }
        guard breaches[day].indices.contains(hour) else {
            return Color(.systemGray6)
        }
        return breaches[day][hour] ? Color.red : Color(.systemGray5)
    }
}

struct AlertNotifyCard: View {
    @Binding var notifies: Bool

    var body: some View {
        AlertCard {
            Button {
                notifies.toggle()
            } label: {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: "This iPhone")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(notifies ? Color.blue : Color.primary)

                        Text(verbatim: notifies ? "Push notification" : "Off")
                            .font(.book(size: 11))
                            .foregroundStyle(notifies ? Color.blue.opacity(0.75) : Color(.systemGray))
                    }

                    Spacer(minLength: 0)

                    if notifies {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: .rowSubtitle)
                .padding(.horizontal, 8)
                .background(notifies ? Color.blue.opacity(0.12) : Color.clear)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

struct AlertFooter: View {
    var body: some View {
        Text(footerText)
            .font(.book(size: 13))
            .lineSpacing(2)
            .foregroundStyle(Color(.systemGray))
            .padding(.top, 4)
    }

    private var footerText: AttributedString {
        var text = AttributedString("Alerts for your whole team and Slack come with Hosted Scout. ")
        var link = AttributedString("Learn more")
        link.link = URL(string: "https://github.com/kasianov-mikhail/scout-server")
        link.foregroundColor = .blue
        text.append(link)
        return text
    }
}

struct AlertCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundStyle(.primary)
        .accessibilityLabel(Text(verbatim: "Close"))
    }
}

struct AlertSaveButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark")
                .font(.system(size: 15, weight: .semibold))
        }
        .disabled(!isEnabled)
        .accessibilityLabel(Text(verbatim: "Save"))
    }
}

private let alertWeekdayFormatter = DateFormatter(format: "EEE")
