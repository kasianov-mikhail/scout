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
    @MainActor struct DeviceRowSnapshotTests {
        @Test("Known model, crash badge, and an unknown model")
        func rows() {
            guard ViewSnapshot.isSupported else { return }

            let now = Date()

            // Relative labels resolve against the current date, so the offsets sit
            // mid-bucket ("2m ago", "25m ago", "2h ago") to stay stable while the
            // snapshot renders.
            let devices = [
                DeviceSummary(
                    id: UUID(),
                    model: "iPhone15,3",
                    osVersion: "iOS 17.4",
                    lastSeen: now.addingTimeInterval(-150),
                    sessions: 812,
                    crashes: 0
                ),
                DeviceSummary(
                    id: UUID(),
                    model: "iPad13,4",
                    osVersion: "iPadOS 26.0",
                    lastSeen: now.addingTimeInterval(-1500),
                    sessions: 19_204,
                    crashes: 37
                ),
                DeviceSummary(
                    id: UUID(),
                    model: nil,
                    osVersion: "—",
                    lastSeen: now.addingTimeInterval(-7500),
                    sessions: 4,
                    crashes: 1
                ),
            ]

            let view = NavigationStack {
                InsetList {
                    ForEach(devices) { device in
                        DeviceRow(device: device)
                    }
                }
            }

            assertSnapshot(of: view, as: .scout(height: 260))
            assertSnapshot(of: view, as: .scout(height: 260, style: .dark), named: "dark")
        }
    }
#endif
