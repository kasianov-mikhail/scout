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
    @MainActor struct PercentileRowSnapshotTests {
        @Test("P50, P90, and P99 latency metrics")
        func metrics() {
            guard ViewSnapshot.isSupported else { return }

            assertSnapshot(of: PercentileRow(percentiles: .sample).padding(), as: .scout(height: 80))
            assertSnapshot(
                of: PercentileRow(percentiles: .sample).padding(),
                as: .scout(height: 80, style: .dark),
                named: "dark"
            )
        }
    }
#endif
