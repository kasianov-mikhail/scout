//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct FunnelBuilder: View {
    @Binding var stepNames: [String]
    @Binding var key: Funnel.CorrelationKey
    let suggestions: [String]

    @State private var showCustomStep = false
    @State private var customStep = ""

    var body: some View {
        Header(title: "Steps")

        ForEach(Array(stepNames.enumerated()), id: \.element) { index, name in
            HStack(spacing: 10) {
                FunnelStepIndex(index: index)
                Text(verbatim: name)
                    .font(.footnote)
                    .monospaced()
            }
        }
        .onDelete { stepNames.remove(atOffsets: $0) }
        .onMove { stepNames.move(fromOffsets: $0, toOffset: $1) }

        if stepNames.count < Funnel.stepLimit.upperBound {
            addStepMenu
        }

        Header(title: "Correlate by")

        Picker(selection: $key) {
            ForEach(Funnel.CorrelationKey.allCases) { key in
                Text(verbatim: key.title)
            }
        } label: {
            Text(verbatim: "Correlate by")
        }
        .pickerStyle(.segmented)
        .listRowSeparator(.hidden)
    }

    private var addStepMenu: some View {
        Menu {
            ForEach(availableSuggestions, id: \.self) { name in
                Button {
                    stepNames.append(name)
                } label: {
                    Text(verbatim: name)
                }
            }
            if availableSuggestions.count > 0 {
                Divider()
            }
            Button {
                customStep = ""
                showCustomStep = true
            } label: {
                Label {
                    Text(verbatim: "Custom Event…")
                } icon: {
                    Image(systemName: "keyboard")
                }
            }
        } label: {
            Label {
                Text(verbatim: "Add Step")
            } icon: {
                Image(systemName: "plus.circle.fill")
            }
        }
        .alert(Text(verbatim: "Custom Event"), isPresented: $showCustomStep) {
            TextField(text: $customStep) {
                Text(verbatim: "Event name")
            }
            .autocorrectionDisabled(true)
            Button {
                addCustomStep()
            } label: {
                Text(verbatim: "Add")
            }
            Button(role: .cancel) {
            } label: {
                Text(verbatim: "Cancel")
            }
        }
    }

    private var availableSuggestions: [String] {
        suggestions.filter { !stepNames.contains($0) }
    }

    private func addCustomStep() {
        let name = customStep.trimmingCharacters(in: .whitespacesAndNewlines)
        guard name.count > 0, !stepNames.contains(name) else { return }
        stepNames.append(name)
    }
}

private struct BuilderPreview: View {
    @State private var stepNames = ["app_open", "signup_started"]
    @State private var key = Funnel.CorrelationKey.session

    var body: some View {
        List {
            FunnelBuilder(
                stepNames: $stepNames,
                key: $key,
                suggestions: FunnelStep.samples.map(\.name)
            )
        }
        .listStyle(.plain)
    }
}

#Preview("Funnel builder") {
    NavigationStack {
        BuilderPreview()
    }
}
