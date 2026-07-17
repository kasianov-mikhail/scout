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

    @Suite(.enabled(if: ViewSnapshot.isSupported))
    @MainActor struct TimelineRowSnapshotTests {
        @Test("Rows with a highlighted middle item")
        func rows() {
            guard ViewSnapshot.isSupported else { return }

            let now = Date()
            let installID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")
            let launchID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")
            let sessionID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")

            // Relative labels resolve against the current date, so the offsets sit
            // mid-bucket ("3m ago", "2m ago", "recently") to stay stable while the
            // snapshot renders.
            let items = ["setup", "ip_lookup", "search"].enumerated().map { index, name in
                TimelineItem(
                    id: name,
                    name: name,
                    date: now.addingTimeInterval([-210, -150, -30][index]),
                    active: [.install, .launch, .session],
                    installID: installID,
                    launchID: launchID,
                    sessionID: sessionID
                )
            }

            let view = VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element) { index, _ in
                    TimelineRow(
                        items: items,
                        index: index,
                        timeline: now,
                        highlighted: index == 1
                    )
                }
            }

            assertSnapshot(of: view, as: .scout(height: 140))
            assertSnapshot(of: view, as: .scout(height: 140, style: .dark), named: "dark")
        }
    }
#endif
