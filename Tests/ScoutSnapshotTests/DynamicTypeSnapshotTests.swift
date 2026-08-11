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

    // The largest accessibility size is where a row clips or collapses first, so
    // these baselines guard the layouts that pack a label, a count, and a
    // timestamp onto one line. `deviceRows` records today's behavior, not the
    // desired one: `DeviceRow` pins itself to a 70pt height, so its text overflows
    // and truncates here. Re-record it once that height gives way.
    @Suite(.enabled(if: ViewSnapshot.isSupported))
    @MainActor struct DynamicTypeSnapshotTests {
        private static let contentSize = UIContentSizeCategory.accessibilityExtraExtraExtraLarge

        @Test("Device rows at the largest accessibility size")
        func deviceRows() {
            guard ViewSnapshot.isSupported else { return }

            let now = Date()

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
            ]

            let view = NavigationStack {
                InsetList {
                    ForEach(devices) { device in
                        DeviceRow(device: device)
                    }
                }
            }

            assertSnapshot(of: view, as: .scout(height: 260, contentSize: Self.contentSize))
            assertSnapshot(
                of: view,
                as: .scout(height: 260, style: .dark, contentSize: Self.contentSize),
                named: "dark"
            )
        }

        @Test("Placeholder at the largest accessibility size")
        func placeholder() {
            guard ViewSnapshot.isSupported else { return }

            let view = Placeholder(
                text: "No crashes",
                systemImage: "checkmark.shield",
                description: "No crash reports have been recorded"
            )

            assertSnapshot(of: view, as: .scout(height: 360, contentSize: Self.contentSize))
            assertSnapshot(
                of: view,
                as: .scout(height: 360, style: .dark, contentSize: Self.contentSize),
                named: "dark"
            )
        }
    }
#endif
