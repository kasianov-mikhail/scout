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

    @testable import ScoutCore

    @testable import ScoutUI

    @Suite(.enabled(if: ViewSnapshot.isSupported))
    @MainActor struct MetricCardSnapshotTests {
        @Test("Loaded, empty, loading, and missing cards")
        func states() {
            guard ViewSnapshot.isSupported else { return }

            let columns = [GridItem(.fixed(162), spacing: 24), GridItem(.fixed(162), spacing: 24)]

            let view = LazyVGrid(columns: columns, spacing: 24) {
                MetricCard(
                    title: "Sessions",
                    color: .purple,
                    summary: MetricSummary(count: 8420, previous: 7500, values: [3, 5, 4, 7, 6, 9, 12])
                )
                MetricCard(
                    title: "Crashes",
                    color: .red,
                    summary: MetricSummary(count: 87, previous: 101, values: [9, 7, 8, 6, 7, 5, 4])
                )
                MetricCard(
                    title: "Empty",
                    color: .red,
                    summary: MetricSummary(count: 0, previous: 0, values: [0, 0, 0, 0, 0, 0, 0])
                )
                MetricCard(title: "Loading", color: .green, summary: .loading)
                MetricCard(title: "Missing", color: .green, summary: nil)
            }
            .padding()

            assertSnapshot(of: view, as: .scout(height: 460))
            assertSnapshot(of: view, as: .scout(height: 460, style: .dark), named: "dark")
        }
    }
#endif
