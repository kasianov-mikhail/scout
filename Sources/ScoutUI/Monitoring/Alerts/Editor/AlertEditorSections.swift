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
        VStack(alignment: .leading, spacing: .space8) {
            Text(verbatim: title.uppercased())
                .font(.scoutFootnoteStrong)
                .tracking(0.3)
                .foregroundStyle(Color.textMuted)

            content()
        }
        .padding(.top, .space22)
    }
}

struct AlertCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: .radiusBlock))
            .overlay {
                RoundedRectangle(cornerRadius: .radiusBlock)
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
        HStack(spacing: .space8) {
            VStack(alignment: .leading, spacing: .space2) {
                Text(verbatim: name.isEmpty ? "Choose event" : name)
                    .font(.book(size: 15, design: name.isEmpty ? .default : .monospaced))
                    .lineLimit(1)
                    .truncationMode(.middle)

                detail
            }

            Spacer(minLength: 0)

            if showsChange {
                Text(verbatim: "Change")
                    .font(.scoutRowStrong)
                    .foregroundStyle(Color.textLink)
            }
        }
        .frame(height: .rowSubtitle)
        .padding(.horizontal, .space8)
        .contentShape(Rectangle())
    }

    @ViewBuilder private var detail: some View {
        if name.isEmpty {
            Text(verbatim: "Tap to pick an event")
                .font(.scoutMicro)
                .foregroundStyle(Color.textMuted)
        } else if let range {
            Text(verbatim: rangeText(range))
                .font(.scoutMicro)
                .foregroundStyle(Color.textMuted)
        } else if isFailed {
            Text(verbatim: "—")
                .font(.scoutMicro)
                .foregroundStyle(Color.textMuted)
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
            VStack(alignment: .leading, spacing: .space12) {
                TextField(text: $name, prompt: Text(verbatim: "Event name")) {
                    Text(verbatim: "Event name")
                }
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .focused($isFocused)

                Spacer()
            }
            .padding(.space16)
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
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: title)
                .font(isSelected ? .scoutRowStrong : .scoutRow)
                .foregroundStyle(isSelected ? Color.fillAccent : Color.textPrimary)

            Text(verbatim: detail)
                .font(.scoutMicro)
                .foregroundStyle(isSelected ? Color.textLink.opacity(0.75) : Color.textMuted)
                .lineLimit(1)
        }
        .padding(.vertical, .space10)
        .padding(.horizontal, .space8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.surfaceSelected : Color.clear)
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
                        .font(.scoutNumberS)
                        .monospacedDigit()

                    Text(verbatim: " \(unit)")
                        .font(.scoutCaption)
                        .foregroundStyle(Color.textMuted)
                }
                .padding(.vertical, .space10)
                .padding(.horizontal, .space8)
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
                .font(.scoutRowStrong)
                .foregroundStyle(Color.textLink)
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
                    .font(.scoutNumberS)
                    .monospacedDigit()
            } else if isFailed {
                Text(verbatim: "—")
                    .font(.scoutNumberS)
            } else {
                SkeletonBar(width: 28, height: 16, delay: 0)
            }

            Text(verbatim: " alerts with \(draft.sensitivity.title)")
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)
        }
        .padding(.vertical, .space10)
        .padding(.horizontal, .space8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func countsRow(_ counts: [AlertDraft.Sensitivity: Int]?) -> some View {
        HStack(spacing: 0) {
            ForEach(AlertDraft.Sensitivity.allCases.indices, id: \.self) { index in
                let sensitivity = AlertDraft.Sensitivity.allCases[index]

                VStack(alignment: .leading, spacing: .space2) {
                    Text(verbatim: sensitivity.title)
                        .font(.scoutMicro)
                        .foregroundStyle(Color.textMuted)

                    if let count = counts?[sensitivity] {
                        Text(verbatim: "\(count)")
                            .font(.scoutRowStrong)
                            .monospacedDigit()
                    } else if isFailed {
                        Text(verbatim: "—")
                            .font(.scoutRowStrong)
                    } else {
                        SkeletonBar(width: 28, height: 11, delay: 0)
                    }
                }
                .padding(.vertical, .space8)
                .padding(.horizontal, .space8)
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
        VStack(spacing: .space2) {
            ForEach(dates.indices, id: \.self) { day in
                HStack(spacing: .space2) {
                    Text(verbatim: alertWeekdayFormatter.string(from: dates[day]))
                        .font(.scoutAxis)
                        .foregroundStyle(Color.textMuted)
                        .frame(width: 34, alignment: .leading)

                    HStack(spacing: .space2) {
                        ForEach(0..<24, id: \.self) { hour in
                            RoundedRectangle(cornerRadius: .radiusBar)
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
                .font(.scoutAxis)
                .foregroundStyle(Color.textMuted)
            }
            .padding(.top, .space4)
        }
        .padding(.vertical, .space10)
        .padding(.horizontal, .space8)
    }

    private func cellColor(_ breaches: [[Bool]]?, day: Int, hour: Int) -> Color {
        guard let breaches else {
            return Color.surfaceGrey
        }
        guard breaches.indices.contains(day) else {
            return Color.surfaceGrey
        }
        guard breaches[day].indices.contains(hour) else {
            return Color.surfaceGrey
        }
        return breaches[day][hour] ? Color.fillDanger : Color.surfaceSkeleton
    }
}

struct AlertNotifyCard: View {
    @Binding var notifies: Bool

    var body: some View {
        AlertCard {
            Button {
                notifies.toggle()
            } label: {
                HStack(spacing: .space8) {
                    VStack(alignment: .leading, spacing: .space2) {
                        Text(verbatim: "This iPhone")
                            .font(.scoutRowStrong)
                            .foregroundStyle(notifies ? Color.fillAccent : Color.textPrimary)

                        Text(verbatim: notifies ? "Push notification" : "Off")
                            .font(.scoutMicro)
                            .foregroundStyle(notifies ? Color.fillAccent.opacity(0.75) : Color.fillLevel)
                    }

                    Spacer(minLength: 0)

                    if notifies {
                        Image(systemName: "checkmark")
                            .font(.scoutLabelCaps)
                            .foregroundStyle(Color.textLink)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: .rowSubtitle)
                .padding(.horizontal, .space8)
                .background(notifies ? Color.surfaceSelected : Color.clear)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

struct AlertFooter: View {
    var body: some View {
        Text(footerText)
            .font(.scoutCaption)
            .lineSpacing(2)
            .foregroundStyle(Color.textMuted)
            .padding(.top, .space4)
    }

    private var footerText: AttributedString {
        var text = AttributedString("Alerts for your whole team and Slack come with Hosted Scout. ")
        var link = AttributedString("Learn more")
        link.link = URL(string: "https://github.com/kasianov-mikhail/scout-server")
        link.foregroundColor = .textLink
        text.append(link)
        return text
    }
}

struct AlertCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.scoutCaptionStrong)
        }
        .foregroundStyle(Color.textPrimary)
        .accessibilityLabel(Text(verbatim: "Close"))
    }
}

struct AlertSaveButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark")
                .font(.scoutRowStrong)
        }
        .disabled(!isEnabled)
        .accessibilityLabel(Text(verbatim: "Save"))
    }
}

private let alertWeekdayFormatter = DateFormatter(format: "EEE")
