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
    @MainActor struct CountBadgeSnapshotTests {
        @Test("Counts, prefixes, and colors")
        func variants() {
            guard ViewSnapshot.isSupported else { return }

            let view = VStack(alignment: .leading, spacing: 16) {
                CountBadge(count: 3)
                CountBadge(count: 128, color: .orange)
                CountBadge(count: 42, prefix: "+", color: .green)
                CountBadge(count: 9218, prefix: "×", color: .blue)
            }
            .padding()

            assertSnapshot(of: view, as: .scout(height: 200))
            assertSnapshot(of: view, as: .scout(height: 200, style: .dark), named: "dark")
        }
    }
#endif
