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

    // The retrying state is deliberately absent: it swaps the button for a
    // `RingIndicator`, which spins off `TimelineView(.animation)` and renders a
    // different rotation on every pass.
    @Suite(.enabled(if: ViewSnapshot.isSupported))
    @MainActor struct ErrorViewSnapshotTests {
        private static let description =
            "The request failed because the backend is unreachable. "
            + "Check the connection and try again."

        @Test("Retryable failure")
        func retryable() {
            guard ViewSnapshot.isSupported else { return }

            let view = ErrorView(description: Self.description, retry: {})

            assertSnapshot(of: view, as: .scout(height: 400))
            assertSnapshot(of: view, as: .scout(height: 400, style: .dark), named: "dark")
        }

        @Test("Terminal failure")
        func terminal() {
            guard ViewSnapshot.isSupported else { return }

            let view = ErrorView(description: Self.description, retry: nil)

            assertSnapshot(of: view, as: .scout(height: 400))
            assertSnapshot(of: view, as: .scout(height: 400, style: .dark), named: "dark")
        }
    }
#endif
