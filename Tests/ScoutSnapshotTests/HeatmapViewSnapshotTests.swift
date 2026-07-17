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
    @MainActor struct HeatmapViewSnapshotTests {
        @Test("Populated grid")
        func populated() {
            guard ViewSnapshot.isSupported else { return }

            assertSnapshot(of: HeatmapView(grid: .sample).padding(), as: .scout(height: 320))
            assertSnapshot(
                of: HeatmapView(grid: .sample).padding(), as: .scout(height: 320, style: .dark), named: "dark")
        }

        @Test("Empty grid")
        func empty() {
            guard ViewSnapshot.isSupported else { return }

            let grid = HeatmapGrid(counts: [[Int]](repeating: [Int](repeating: 0, count: 24), count: 7))
            assertSnapshot(of: HeatmapView(grid: grid).padding(), as: .scout(height: 320))
            assertSnapshot(
                of: HeatmapView(grid: grid).padding(), as: .scout(height: 320, style: .dark), named: "dark")
        }
    }
#endif
