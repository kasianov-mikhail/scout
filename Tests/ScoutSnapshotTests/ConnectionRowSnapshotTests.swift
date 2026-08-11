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
    @MainActor struct ConnectionRowSnapshotTests {
        @Test("Reachable, unknown, and unreachable rows with the first one active")
        func rows() {
            guard ViewSnapshot.isSupported else { return }

            let connections = [Connection].samples

            let view = VStack(spacing: 0) {
                ForEach(Array(connections.enumerated()), id: \.element.id) { index, connection in
                    ConnectionRow(
                        connection: connection,
                        isActive: index == 0,
                        showsSeparator: index < connections.count - 1,
                        action: {}
                    )
                }
            }
            .frame(width: 280)

            assertSnapshot(of: view, as: .scout(height: 160))
            assertSnapshot(of: view, as: .scout(height: 160, style: .dark), named: "dark")
        }
    }
#endif
