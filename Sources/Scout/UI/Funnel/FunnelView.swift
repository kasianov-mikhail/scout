//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct FunnelView: View {
    @Environment(\.database) var database

    @AppStorage("scout_funnel_steps") private var storedSteps = ""
    @AppStorage("scout_funnel_key") private var key = Funnel.CorrelationKey.session
    @AppStorage("scout_funnel_period") private var period = Period.month

    @StateObject private var provider: FunnelProvider
    @StateObject private var suggestions = EventProvider()

    init(steps: [String] = [], provider: FunnelProvider = FunnelProvider()) {
        self._storedSteps = AppStorage(wrappedValue: steps.joined(separator: "\n"), "scout_funnel_steps")
        self._provider = StateObject(wrappedValue: provider)
    }

    private struct FetchID: Hashable {
        let steps: String
        let period: Period
    }

    var body: some View {
        List {
            FunnelBuilder(stepNames: stepNames, key: $key, suggestions: suggestionNames)
            results
        }
        .listStyle(.plain)
        .navigationTitle(en: "Funnel")
        .task {
            await suggestions.fetchIfNeeded(for: Event.Query(), in: database)
        }
        .task(id: FetchID(steps: storedSteps, period: period)) {
            guard funnel.isRunnable else { return }
            await provider.fetchIfNeeded(names: funnel.stepNames, range: period.initialRange, in: database)
        }
        .refreshable {
            guard funnel.isRunnable else { return }
            await provider.refresh(names: funnel.stepNames, range: period.initialRange, in: database)
        }
    }

    @ViewBuilder private var results: some View {
        Header(title: "Funnel") {
            CompactPeriodPicker(selection: $period)
        }

        if !funnel.isRunnable {
            hint("Add \(Funnel.stepLimit.lowerBound) to \(Funnel.stepLimit.upperBound) steps to build the funnel.")
        } else {
            switch provider.result {
            case nil:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 32)
            case .failure(let error):
                hint(error.localizedDescription)
                Button {
                    Task {
                        await provider.refresh(names: funnel.stepNames, range: period.initialRange, in: database)
                    }
                } label: {
                    Text(verbatim: "Retry")
                }
                .listRowSeparator(.hidden)
            case .success(let events):
                steps(from: events)
            }
        }
    }

    @ViewBuilder private func steps(from events: [Event]) -> some View {
        let steps = funnel.steps(from: events)

        if steps.metrics.count == 0 {
            hint("No matching events in this period.")
        } else {
            FunnelPlotView(steps: steps)
                .padding(.vertical, 12)
                .listRowSeparator(.hidden)

            ForEach(steps.metrics) { metric in
                Row {
                    FunnelLegendRow(metric: metric)
                } destination: {
                    FunnelStepDetail(
                        metric: metric,
                        droppedIDs: funnel.droppedIDs(before: metric.index, from: events),
                        key: key
                    )
                }
            }
        }
    }

    private func hint(_ text: String) -> some View {
        Text(verbatim: text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .listRowSeparator(.hidden)
    }

    private var funnel: Funnel {
        Funnel(stepNames: stepNames.wrappedValue, key: key)
    }

    private var stepNames: Binding<[String]> {
        Binding(
            get: { storedSteps.count > 0 ? storedSteps.components(separatedBy: "\n") : [] },
            set: { storedSteps = $0.joined(separator: "\n") }
        )
    }

    private var suggestionNames: [String] {
        suggestions.events?.unique(by: \.name, max: 12) ?? []
    }
}

#Preview("Funnel") {
    NavigationStack {
        FunnelView(steps: FunnelStep.samples.map(\.name), provider: .fixture())
    }
}
