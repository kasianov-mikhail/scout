//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct FunnelStepDetail: View {
    static let displayedDropLimit = 50

    let metric: FunnelStepMetrics
    let droppedIDs: [UUID]
    let key: Funnel.CorrelationKey

    @Environment(\.database) var database
    @StateObject private var cohort: FunnelCohortProvider

    init(metric: FunnelStepMetrics, droppedIDs: [UUID], key: Funnel.CorrelationKey, cohort: FunnelCohortProvider = FunnelCohortProvider()) {
        self.metric = metric
        self.droppedIDs = droppedIDs
        self.key = key
        self._cohort = StateObject(wrappedValue: cohort)
    }

    var body: some View {
        List {
            summary

            if droppedIDs.count > 0 {
                dropped
            }
        }
        .listStyle(.plain)
        .navigationTitle(en: metric.step.name)
        .task {
            await cohort.fetchIfNeeded(ids: displayedIDs, key: key, in: database)
        }
    }

    @ViewBuilder private var summary: some View {
        row(title: "Reached", value: metric.step.count.formatted(), color: .blue)
        row(title: "Share of first step", value: metric.fractionOfFirst.funnelPercent, color: .secondary)
        if let conversion = metric.conversionFromPrevious {
            row(title: "From previous step", value: conversion.funnelPercent, color: .secondary)
            row(title: "Dropped", value: metric.dropOff.formatted(), color: .red)
        }
    }

    @ViewBuilder private var dropped: some View {
        Header(title: "Dropped \(key.title)s")

        switch cohort.result {
        case nil:
            ProgressView()
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
                .padding(.vertical, 16)
        case .failure(let error):
            Text(verbatim: error.localizedDescription)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
            Button {
                Task {
                    await cohort.refresh(ids: displayedIDs, key: key, in: database)
                }
            } label: {
                Text(verbatim: "Retry")
            }
            .listRowSeparator(.hidden)
        case .success(let events):
            entryRows(from: events)
        }
    }

    @ViewBuilder private func entryRows(from events: [Event]) -> some View {
        ForEach(events.cohortEntries(for: displayedIDs, key: key)) { entry in
            entryRow(for: entry)
        }

        if droppedIDs.count > Self.displayedDropLimit {
            Text(verbatim: "And \(droppedIDs.count - Self.displayedDropLimit) more…")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .listRowSeparator(.hidden)
        }
    }

    private func entryRow(for entry: FunnelCohortEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                if let event = entry.lastEvent {
                    Text(verbatim: "last: \(event.name)")
                        .font(.footnote)
                        .monospaced()
                }
                Text(verbatim: entry.groupID.uuidString)
                    .font(.caption2)
                    .monospaced()
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            if let date = entry.lastEvent?.date {
                Text(verbatim: date.relativeString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func row(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(verbatim: title)
            Spacer()
            Text(verbatim: value)
                .monospacedDigit()
                .foregroundStyle(color)
        }
    }

    private var displayedIDs: [UUID] {
        Array(droppedIDs.prefix(Self.displayedDropLimit))
    }
}

#Preview("Funnel step detail") {
    let metrics = FunnelStep.samples.metrics
    let ids = (0..<8).map { _ in UUID() }

    let cohort = FunnelCohortProvider()
    cohort.result = .success(
        ids.map { id in
            Event.sample("signup_started", at: Date().addingTimeInterval(-.random(in: 600...86400)), sessionID: id)
        }
    )

    return NavigationStack {
        FunnelStepDetail(metric: metrics[2], droppedIDs: ids, key: .session, cohort: cohort)
    }
}
