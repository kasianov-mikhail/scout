//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

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
