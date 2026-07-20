//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AlertListView: View {
    @ObservedObject var provider: AlertProvider

    @Environment(\.database) private var database
    @State private var isEditorPresented = false

    var body: some View {
        content
            .navigationTitle(en: "Alerts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isEditorPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isEditorPresented) {
                Task { await provider.fetchAgain(in: database) }
            } content: {
                NavigationStack {
                    AlertEditorView(provider: provider)
                }
            }
            .opaquePresentation()
            .task { await provider.fetchIfNeeded(in: database) }
            .refreshable { await provider.fetchAgain(in: database) }
    }

    @ViewBuilder private var content: some View {
        switch provider.result {
        case .success(let statuses) where statuses.count > 0:
            List {
                chips(statuses)

                Header(title: "Rules") {
                    if statuses.firingCount > 0 {
                        CountBadge(count: statuses.firingCount)
                    }
                }

                ForEach(statuses, id: \.rule) { status in
                    AlertRow(status: status)
                        .swipeActions {
                            Button(role: .destructive) {
                                provider.remove(status.rule)
                                Task { await provider.fetchAgain(in: database) }
                            } label: {
                                Text(verbatim: "Delete")
                            }
                        }
                }
            }
            .listStyle(.plain)

        case .success:
            Placeholder(
                text: "No alert rules",
                systemImage: "bell.badge",
                description: "Add a rule to get notified when a metric misbehaves."
            )

        case .failure(let error):
            ErrorView(description: error.localizedDescription) {
                await provider.fetchAgain(in: database)
            }

        case nil:
            List {
                Header(title: "Rules")

                ForEach(0..<3, id: \.self) { _ in
                    AlertRowPlaceholder()
                }
            }
            .listStyle(.plain)
        }
    }

    private func chips(_ statuses: [AlertStatus]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(statuses, id: \.rule) { status in
                    AlertChip(status: status)
                }
            }
        }
        .listRowSeparator(.hidden)
    }
}

private struct AlertChip: View {
    let status: AlertStatus

    var body: some View {
        Label {
            Text(verbatim: text)
        } icon: {
            Image(systemName: status.outcome.state.icon)
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(status.outcome.state.color)
        .padding(.horizontal, 13)
        .padding(.vertical, 8)
        .background(status.outcome.state.color.opacity(0.12), in: Capsule())
    }

    private var text: String {
        guard let current = status.reading.recent.last else { return status.rule.metric.title }
        return "\(status.rule.metric.title) \(status.rule.metric.format(current))"
    }
}

#Preview {
    let provider = AlertProvider()
    provider.result = .success([.firingSample, .armedSample])

    return NavigationStack {
        AlertListView(provider: provider)
    }
}

#Preview("Empty") {
    let provider = AlertProvider()
    provider.result = .success([])

    return NavigationStack {
        AlertListView(provider: provider)
    }
}

extension AlertStatus {
    static var firingSample: AlertStatus {
        AlertStatus(
            rule: AlertRule(
                metric: .crashFreeSessions,
                condition: AlertCondition(comparison: .below, reference: .constant(0.995)),
                holdBuckets: 2
            ),
            outcome: AlertOutcome(
                state: .firing(since: Date(timeIntervalSinceReferenceDate: 803_500_000)),
                shouldNotify: false
            ),
            reading: MetricReading(
                baseline: 0.998,
                recent: [0.998, 0.998, 0.997, 0.996, 0.994, 0.989, 0.982]
            )
        )
    }

    static var armedSample: AlertStatus {
        AlertStatus(
            rule: AlertRule(
                metric: .eventCount(name: "Error"),
                condition: AlertCondition(comparison: .above, reference: .medianFactor(3))
            ),
            outcome: AlertOutcome(state: .armed, shouldNotify: false),
            reading: MetricReading(baseline: 4, recent: [4, 3, 4, 5, 3, 4, 5])
        )
    }
}
