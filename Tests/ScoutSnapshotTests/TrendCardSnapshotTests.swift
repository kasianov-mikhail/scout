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
    @MainActor struct TrendCardSnapshotTests {
        @Test("Loaded, empty, loading, and missing cards")
        func states() {
            guard ViewSnapshot.isSupported else { return }

            let columns = [GridItem(.fixed(162), spacing: 24), GridItem(.fixed(162), spacing: 24)]

            let view = LazyVGrid(columns: columns, spacing: 24) {
                TrendCard(
                    title: "Sessions",
                    color: .purple,
                    trend: Trend(count: 8420, previous: 7500, values: [3, 5, 4, 7, 6, 9, 12])
                )
                TrendCard(
                    title: "Crashes",
                    color: .red,
                    trend: Trend(count: 87, previous: 101, values: [9, 7, 8, 6, 7, 5, 4])
                )
                TrendCard(
                    title: "Empty",
                    color: .red,
                    trend: Trend(count: 0, previous: 0, values: [0, 0, 0, 0, 0, 0, 0])
                )
                TrendCard(title: "Loading", color: .green, trend: .loading)
                TrendCard(title: "Missing", color: .green, trend: nil)
            }
            .padding()

            assertSnapshot(of: view, as: .scout(height: 460))
            assertSnapshot(of: view, as: .scout(height: 460, style: .dark), named: "dark")
        }
    }
#endif
