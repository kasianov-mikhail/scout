//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if canImport(UIKit)
    import SnapshotTesting
    import SwiftUI
    import Testing

    @testable import Scout

    @testable import ScoutUI

    @Suite(.enabled(if: ViewSnapshot.isSupported))
    @MainActor struct NetworkEndpointRowSnapshotTests {
        @Test("Endpoints across the success-rate range")
        func rows() {
            guard ViewSnapshot.isSupported else { return }

            let report = NetworkReport.sample
            let range = Period.today.initialRange

            let view = NavigationStack {
                InsetList {
                    ForEach(NetworkEndpoint.samples) { endpoint in
                        NetworkEndpointRow(endpoint: endpoint, report: report, range: range)
                    }
                }
            }

            assertSnapshot(of: view, as: .scout(height: 400))
            assertSnapshot(of: view, as: .scout(height: 400, style: .dark), named: "dark")
        }
    }
#endif
