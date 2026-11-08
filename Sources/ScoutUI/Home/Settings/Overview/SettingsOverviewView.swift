//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout
import SwiftUI

struct SettingsOverviewView: View {
    @Binding var activeID: String
    @StateObject var health: BackendHealthProvider
    @StateObject private var cacheStatus: CacheStatus

    let send: SendSummary

    @State private var start = StartPeriod.today
    @State private var pushes = true
    @State private var isClearing = false

    init(backends: [Backend], activeID: Binding<String>, cache: any CacheClearing, health: BackendHealthProvider? = nil, send: SendSummary = .sample) {
        self._activeID = activeID
        self.send = send
        self._health = StateObject(wrappedValue: health ?? BackendHealthProvider(backends: backends))
        self._cacheStatus = StateObject(wrappedValue: CacheStatus(cache: cache))
    }

    var body: some View {
        InsetList {
            VStack(alignment: .leading, spacing: 0) {
                SettingsLabel(title: "READ FROM")

                if health.backends.isEmpty {
                    SettingsCard {
                        Text(verbatim: "No backends configured.")
                            .font(.weight450(size: 15))
                            .foregroundStyle(Color(.systemGray))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 10)
                    }
                } else {
                    SettingsStrip {
                        ForEach(health.backends) { backend in
                            NavigationLink {
                                BackendDetailView(provider: health, id: backend.id, activeID: $activeID)
                            } label: {
                                SettingsSegmentCell(
                                    title: backend.name,
                                    detail: backend.detailLabel,
                                    state: backend.segmentState,
                                    isSelected: backend.id == activeID,
                                    showsDivider: backend.id != health.backends.last?.id
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                SettingsNote(text: "All backends get the data. Scout reads from the one you pick.")

                SettingsLabel(title: "START ON")

                SettingsStrip {
                    ForEach(StartPeriod.allCases) { period in
                        Button {
                            start = period
                        } label: {
                            SettingsSegmentCell(
                                title: period.title,
                                isSelected: start == period,
                                showsDivider: period != StartPeriod.allCases.last
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .hapticFeedback(.selection, trigger: start)

                SettingsLabel(title: "ALERT PUSHES")

                SettingsStrip {
                    segment(title: "On", isSelected: pushes, showsDivider: true) {
                        pushes = true
                    }

                    segment(title: "Off", isSelected: !pushes, showsDivider: false) {
                        pushes = false
                    }
                }
                .hapticFeedback(.selection, trigger: pushes)

                SettingsNote(text: "Firing rules notify this iPhone.")

                SettingsLabel(title: "SENDING FROM THIS IPHONE")

                SettingsCard {
                    SendReadout(summary: send)
                }

                SettingsNote(text: "Scout sends and checks in the background on its own.")

                SettingsLabel(title: "CACHE")

                SettingsCard {
                    HStack(spacing: 0) {
                        SettingsReadoutRow(
                            value: cacheStatus.bytes == nil ? nil : cacheStatus.sizeLabel,
                            caption: "on this iPhone"
                        )

                        SettingsCardAction(title: "Clear", color: .red) {
                            isClearing = true
                        }
                    }
                }

                Text(verbatim: version)
                    .font(.weight450(size: 13))
                    .foregroundStyle(Color(.systemGray))
                    .padding(.top, 22)
            }
            .listRowSeparator(.hidden)
        }
        .navigationTitle(en: "Settings")
        .inlineNavigationTitle()
        .dismissable()
        .fetchTask([health])
        .task {
            await cacheStatus.refresh()
        }
        .confirmationDialog(
            Text(verbatim: "Clear the cached data?"),
            isPresented: $isClearing,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                Task { await cacheStatus.clear() }
            } label: {
                Text(verbatim: "Clear Cache")
            }

            Button(role: .cancel) {
            } label: {
                Text(verbatim: "Cancel")
            }
        } message: {
            Text(verbatim: "Charts and lists will reload from the backend on their next refresh.")
        }
    }

    private var version: String {
        Bundle.main.marketingVersion.map { "Scout \($0)" } ?? "Scout"
    }

    private func segment(title: String, isSelected: Bool, showsDivider: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            SettingsSegmentCell(title: title, isSelected: isSelected, showsDivider: showsDivider)
        }
        .buttonStyle(.plain)
    }
}

private enum StartPeriod: CaseIterable, Identifiable {
    case today
    case week
    case month
    case year

    var id: Self { self }

    var title: String {
        switch self {
        case .today:
            "Today"
        case .week:
            "7 days"
        case .month:
            "30 days"
        case .year:
            "Year"
        }
    }
}

private struct SendReadout: View {
    let summary: SendSummary

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if let pending = summary.pending {
                Text(verbatim: "\(pending)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            } else {
                SkeletonBar(width: 28, height: 16, delay: 0)
            }

            Text(verbatim: "records waiting")
                .font(.weight450(size: 13))
                .foregroundStyle(Color(.systemGray))

            if let lastSent = summary.lastSent {
                Text(verbatim: "· sent \(lastSent)")
                    .font(.weight450(size: 13))
                    .foregroundStyle(Color(.systemGray))
            } else {
                Text(verbatim: "·")
                    .font(.weight450(size: 13))
                    .foregroundStyle(Color(.systemGray))
                SkeletonBar(width: 74, height: 9, delay: 0)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Settings") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        SettingsOverviewView(
            backends: [],
            activeID: $activeID,
            cache: CacheSample(size: 18_400_000),
            health: BackendHealthProvider(healths: .samples)
        )
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Loading") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        SettingsOverviewView(
            backends: [],
            activeID: $activeID,
            cache: CacheSample(size: 18_400_000),
            health: BackendHealthProvider(
                healths: [BackendHealth].samples.map { health in
                    var health = health
                    health.status = nil
                    health.probe = { .reachable }
                    return health
                }),
            send: .loading
        )
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("No Backends") {
    @Previewable @State var activeID = ""
    NavigationStack {
        SettingsOverviewView(backends: [], activeID: $activeID, cache: CacheSample())
    }
}
