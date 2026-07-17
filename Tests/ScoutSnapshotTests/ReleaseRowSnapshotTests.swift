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

    @testable import ScoutTestSupport

    @Suite(.enabled(if: ViewSnapshot.isSupported))
    @MainActor struct ReleaseRowSnapshotTests {
        @Test("Release health rows and a loading placeholder")
        func rows() {
            guard ViewSnapshot.isSupported else { return }

            let view = NavigationStack {
                List {
                    ForEach([ReleaseHealth].samples) { release in
                        ReleaseRow(release: release)
                    }
                    ReleaseRowPlaceholder()
                }
                .listStyle(.plain)
            }

            assertSnapshot(of: view, as: .scout(height: 360))
            assertSnapshot(of: view, as: .scout(height: 360, style: .dark), named: "dark")
        }
    }
#endif
