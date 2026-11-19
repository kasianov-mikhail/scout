//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
#Preview("Server") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        BackendDetailView(
            provider: BackendHealthProvider(healths: .samples),
            id: [BackendHealth].samples[0].id,
            activeID: $activeID,
            report: .sample(engine: [BackendHealth].samples[0].engine)
        )
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("CloudKit") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        BackendDetailView(
            provider: BackendHealthProvider(healths: .samples),
            id: [BackendHealth].samples[1].id,
            activeID: $activeID,
            report: .sample(engine: [BackendHealth].samples[1].engine)
        )
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Loading") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        BackendDetailView(
            provider: BackendHealthProvider(healths: .samples),
            id: [BackendHealth].samples[2].id,
            activeID: $activeID,
            report: BackendReport()
        )
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Unreachable") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        BackendDetailView(
            provider: BackendHealthProvider(healths: .samples),
            id: [BackendHealth].samples[3].id,
            activeID: $activeID,
            report: .sample(engine: [BackendHealth].samples[3].engine)
        )
    }
}
