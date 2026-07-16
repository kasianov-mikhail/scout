//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SnapshotTesting
import SwiftUI
import Testing

@testable import Scout

@Suite(.enabled(if: ViewSnapshot.isSupported))
@MainActor struct SparklineSnapshotTests {
    @Test("Rising, falling, flat, and empty series")
    func states() {
        guard ViewSnapshot.isSupported else { return }

        let view = VStack(spacing: 24) {
            Sparkline(series: MiniChartSeries(values: [3, 5, 4, 7, 6, 9, 12]), color: .purple)
                .frame(height: 60)
            Sparkline(series: MiniChartSeries(values: [9, 7, 8, 6, 7, 5, 4]), color: .red)
                .frame(height: 60)
            Sparkline(series: MiniChartSeries(values: [4, 4, 4, 4, 4, 4, 4]), color: .green)
                .frame(height: 60)
            Sparkline(series: .empty, color: .orange)
                .frame(height: 60)
        }
        .padding()

        assertSnapshot(of: view, as: .scout(height: 400))
        assertSnapshot(of: view, as: .scout(height: 400, style: .dark), named: "dark")
    }
}
