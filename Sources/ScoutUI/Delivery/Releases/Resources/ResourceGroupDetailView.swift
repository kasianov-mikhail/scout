//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ResourceGroupDetailView: View {
    @StateObject private var occurrences: IncidentOccurrencesProvider<ResourceException>
    @StateObject private var breakdown: IncidentBreakdownProvider
    @Environment(\.database) var database

    init(group: IncidentGroup<ResourceException>, breakdown: IncidentBreakdownProvider? = nil) {
        _occurrences = StateObject(wrappedValue: IncidentOccurrencesProvider(group: group))
        _breakdown = StateObject(
            wrappedValue: breakdown
                ?? IncidentBreakdownProvider(
                    deviceIDs: group.deviceIDs,
                    sessionIDs: group.sessionIDs
                )
        )
    }

    init(occurrences: IncidentOccurrencesProvider<ResourceException>) {
        _occurrences = StateObject(wrappedValue: occurrences)
        _breakdown = StateObject(
            wrappedValue: IncidentBreakdownProvider(
                deviceIDs: occurrences.group.deviceIDs,
                sessionIDs: occurrences.group.sessionIDs
            )
        )
    }

    var body: some View {
        Group {
            if let records = occurrences.records {
                if records.isEmpty {
                    Placeholder(text: "No occurrences")
                } else {
                    content(records: records)
                        .transition(.opacity)
                }
            } else if let error = occurrences.error {
                ErrorView(description: error.localizedDescription) {
                    await occurrences.fetchIfNeeded(in: database)
                }
            } else {
                IncidentGroupPlaceholder(kind: .resource, resourceKind: occurrences.group.records.first?.resourceKind)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: occurrences.records == nil)
        .message($occurrences.message)
        .toolbarBackground(IncidentKind.resource.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .monospacedNavigationTitle(en: occurrences.name)
        .task {
            await occurrences.fetchIfNeeded(in: database)
        }
        .task(id: occurrences.records?.map(\.id)) {
            if occurrences.records != nil {
                await breakdown.fetch(deviceIDs: occurrences.group.deviceIDs, sessionIDs: occurrences.group.sessionIDs, in: database)
            }
        }
    }

    private func content(records: [ResourceException]) -> some View {
        IncidentSummaryView(
            summary: summary(records: records),
            records: records,
            row: occurrenceRow
        ) {
            IncidentOccurrencesView(occurrences: occurrences, row: occurrenceRow)
        }
    }

    private func summary(records: [ResourceException]) -> IncidentSummary {
        let group = occurrences.group
        let heaviest = group.heaviest
        return IncidentSummary(
            kind: .resource,
            label: "Resource · MetricKit",
            message: heaviest.reason,
            group: group,
            breakdown: breakdown.value,
            cards: [
                .occurrences(records: records, value: group.occurrencesText),
                .peak(records: records),
            ],
            stack: heaviest.stackTrace
        )
    }

    private func occurrenceRow(_ resource: ResourceException) -> some View {
        Row {
            if let date = resource.date {
                Text(verbatim: date.relativeString)
                    .font(.system(size: 15))
            }

            Spacer()

            if let label = breakdown.value?.occurrenceLabel(record: resource) {
                Text(verbatim: label)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(1)
            }
        } destination: {
            ResourceDetailView(resource: resource, group: group)
        }
    }
}

extension IncidentGroup where Element == ResourceException {
    fileprivate var heaviest: ResourceException {
        records.max { amount(resource: $0) < amount(resource: $1) } ?? representative
    }

    fileprivate func amount(resource: ResourceException) -> Double {
        ResourceAmount(reason: resource.reason)?.value ?? 0
    }
}

#Preview {
    NavigationStack {
        ResourceGroupDetailView(
            group: IncidentGroup(records: [ResourceException].samples.filter { $0.resourceKind == .cpu }),
            breakdown: .init(.success(.sample), deviceIDs: [], sessionIDs: [])
        )
    }
    .environmentObject(Tint())
}
