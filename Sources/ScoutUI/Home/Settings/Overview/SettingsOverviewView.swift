//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct SettingsOverviewView: View {
    @Binding var activeID: String
    @StateObject var provider: BackendHealthProvider

    let backends: [Backend]
    let cache: any CacheClearing

    init(backends: [Backend], activeID: Binding<String>, cache: any CacheClearing, provider: BackendHealthProvider? = nil) {
        self.backends = backends
        self._activeID = activeID
        self.cache = cache
        self._provider = StateObject(wrappedValue: provider ?? BackendHealthProvider(backends: backends))
    }

    var body: some View {
        InsetList {
            GlanceHero(summary: GlanceSummary(backends: provider.backends))
                .padding(.vertical, 6)
                .padding(.top)
                .listRowSeparator(.hidden)

            if !provider.backends.isEmpty {
                Header(title: "Backends")

                ForEach(provider.backends) { backend in
                    Row {
                        BackendRow(backend: backend, isActive: backend.id == activeID)
                    } destination: {
                        BackendDetailView(provider: provider, id: backend.id, activeID: $activeID)
                    }
                }
            }

            if !backends.isEmpty {
                CacheSection(cache: cache)
            }

            if !provider.backends.isEmpty {
                Header(title: "Diagnostics")

                Button {
                    Task { await provider.refreshAll() }
                } label: {
                    Text(verbatim: "Check All Backends").foregroundStyle(.tint)
                }
            }
        }
        .navigationTitle(en: "Settings")
        .dismissable()
        .refreshes([provider])
    }
}

private struct BackendRow: View {
    let backend: BackendHealth
    let isActive: Bool

    var body: some View {
        Circle()
            .fill(backend.status.healthColor)
            .frame(width: 8, height: 8)

        Text(verbatim: backend.name)

        if isActive {
            Text(verbatim: "Active")
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(.tint.opacity(0.15)))
                .foregroundStyle(.tint)
        }

        Spacer()

        Text(verbatim: backend.latencyLabel)
            .font(.body.monospacedDigit())
            .foregroundStyle(.secondary)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Settings") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        SettingsOverviewView(
            backends: .samples,
            activeID: $activeID,
            cache: CacheSample(),
            provider: BackendHealthProvider(healths: .samples)
        )
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Degraded") {
    @Previewable @State var activeID = ""
    NavigationStack {
        SettingsOverviewView(
            backends: [],
            activeID: $activeID,
            cache: CacheSample(),
            provider: BackendHealthProvider(healths: Array([BackendHealth].samples.suffix(2)))
        )
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Checking") {
    @Previewable @State var activeID = [Backend].samples[0].id
    NavigationStack {
        SettingsOverviewView(
            backends: .samples,
            activeID: $activeID,
            cache: CacheSample(),
            provider: BackendHealthProvider(backends: .samples)
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
