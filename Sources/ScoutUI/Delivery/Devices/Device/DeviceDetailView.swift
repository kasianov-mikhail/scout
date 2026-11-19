//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct DeviceDetailView: View {
    @StateObject private var provider: DeviceDetailProvider

    @Environment(\.database) private var database
    @State private var showTimeline = false

    init(device: DeviceSummary, range: IncidentRange = .week, provider: DeviceDetailProvider? = nil) {
        _provider = StateObject(wrappedValue: provider ?? DeviceDetailProvider(device: device, range: range))
    }

    var body: some View {
        Group {
            if let error = provider.error {
                ErrorView(description: Text(verbatim: error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            } else {
                ScrollView {
                    if case .success(let detail) = provider.result {
                        content(detail)
                            .transition(.opacity)
                    } else {
                        DeviceDetailPlaceholder(range: $provider.range)
                            .transition(.opacity)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .loadingInk(isLoading: provider.isLoading)
        .navigationTitle(en: "Device")
        .inlineNavigationTitle()
        .navigationDestination(isPresented: $showTimeline) {
            Timeline(deviceID: provider.device.id)
        }
        .task(id: provider.range) {
            await provider.fetchAgain(in: database)
        }
    }

    private func content(_ detail: DeviceDetail) -> some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            RangeStrip(selection: $provider.range, ranges: IncidentRange.allCases, title: \.title)

            subtitle(detail.summary)
                .padding(.top, .space4)
                .padding(.bottom, .space12)
                .padding(.horizontal, .gutter)
                .overlay(alignment: .bottom) {
                    Separator()
                        .padding(.horizontal, .gutter)
                }

            stats(detail)
                .padding(.horizontal, .gutter)

            Section(title: "Sessions") {
                Button {
                    showTimeline = true
                } label: {
                    Text(verbatim: "TIMELINE")
                        .font(.scoutSectionAction)
                        .foregroundStyle(Color.textLink)
                }
                .buttonStyle(.plain)
            } content: {
                if detail.recentSessions.isEmpty {
                    Text(verbatim: "No sessions in this period")
                        .font(.scoutRow)
                        .foregroundStyle(Color.textMuted)
                        .lineLimit(1)
                        .frame(height: .rowRegular)
                } else {
                    ForEach(Array(detail.recentSessions.enumerated()), id: \.element.id) { index, session in
                        sessionRow(
                            session,
                            deviceID: detail.summary.id,
                            maxDuration: detail.maxSessionDuration,
                            showsDivider: index < detail.recentSessions.count - 1
                        )
                    }
                }
            }

            if !detail.history.isEmpty {
                Section(title: "History") {
                    ForEach(Array(detail.history.enumerated()), id: \.element.id) { index, event in
                        HistoryRow(event: event, isLast: index == detail.history.count - 1)
                    }
                }
            }

            Section(title: "Activity", note: detail.activeDaysLabel, bottomGap: 0) {
                DeviceActivityChart(points: detail.activity, showsCounts: detail.range != .month)
                    .padding(.top, .space12)

                Text(verbatim: detail.activityCaption)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
                    .padding(.top, .space12)
                    .padding(.bottom, .space16)
            }

            Section(title: "When it is used", bottomGap: 0) {
                UsageGrid(usage: detail.usage)
                    .padding(.top, .space12)

                Text(verbatim: detail.usageCaption)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
                    .padding(.top, .space12)
                    .padding(.bottom, .space16)
            }
        }
    }

    private func subtitle(_ summary: DeviceSummary) -> some View {
        Text(verbatim: "\(summary.modelName) · \(summary.osVersion) · seen \(summary.lastSeen.relativeString)")
            .font(.scoutRow)
            .foregroundStyle(Color.textMuted)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
