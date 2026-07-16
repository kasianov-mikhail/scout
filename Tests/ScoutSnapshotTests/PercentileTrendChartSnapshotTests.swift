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

    @Suite(.enabled(if: ViewSnapshot.isSupported))
    @MainActor struct PercentileTrendChartSnapshotTests {
        @Test("Hourly P99 trend area")
        func trend() {
            guard ViewSnapshot.isSupported else { return }

            assertSnapshot(of: PercentileTrendChart(trend: .sample, unit: .hour).padding(), as: .scout(height: 320))
            assertSnapshot(
                of: PercentileTrendChart(trend: .sample, unit: .hour).padding(),
                as: .scout(height: 320, style: .dark),
                named: "dark"
            )
        }
    }
#endif
