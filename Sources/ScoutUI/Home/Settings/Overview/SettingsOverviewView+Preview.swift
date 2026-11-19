//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
#Preview("Settings") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        SettingsOverviewView(
            backends: [],
            activeID: $activeID,
            cache: CacheSample(size: 18_400_000),
            health: BackendHealthProvider(healths: .samples),
            send: .sample
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
        SettingsOverviewView(backends: [], activeID: $activeID, cache: CacheSample(), send: .loading)
    }
}
