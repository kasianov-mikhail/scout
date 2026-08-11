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
    @MainActor struct RowSummarySnapshotTests {
        @Test("Loaded, wide, loading, and empty summaries")
        func states() {
            guard ViewSnapshot.isSupported else { return }

            let view = NavigationStack {
                InsetList {
                    summary("Loaded", values: [2, 4, 3, 7, 6, 11, 16], count: 49, color: .red)
                    summary("Wide count", values: [3, 1, 4, 1, 5, 9, 2], count: 19_989, color: .green)
                    summary("Loading", values: nil, count: nil, color: .purple)
                    summary("Empty", values: Array(repeating: 0, count: 7), count: 0, color: .blue)
                }
            }

            assertSnapshot(of: view, as: .scout(height: 260))
            assertSnapshot(of: view, as: .scout(height: 260, style: .dark), named: "dark")
        }

        private func summary(_ label: String, values: [Int]?, count: Int?, color: Color) -> some View {
            HStack {
                Text(verbatim: label)
                Spacer()
                RowSummary(
                    series: values.map(MiniChartSeries.init) ?? .empty,
                    count: count,
                    color: color
                )
            }
        }
    }
#endif
