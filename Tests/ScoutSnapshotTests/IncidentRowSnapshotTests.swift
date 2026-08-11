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
    @MainActor struct IncidentRowSnapshotTests {
        // Relative labels resolve against the current date, so the offsets sit
        // mid-bucket ("2m ago", "25m ago", "2h ago") to stay stable while the
        // snapshot renders.
        private static let offsets: [TimeInterval] = [-150, -1500, -7500]

        @Test("Crash groups with and without a repeat count")
        func crashes() {
            guard ViewSnapshot.isSupported else { return }

            let now = Date()
            let names = ["NSRangeException", "Fatal error", "SIGSEGV"]
            let counts = [8, 1, 3]

            let groups = zip(names, zip(counts, Self.offsets)).map { name, entry in
                IncidentGroup(
                    records: (0..<entry.0).map { index in
                        Crash.sample(name, at: now.addingTimeInterval(entry.1 - Double(index)), sessionID: UUID())
                    }
                )
            }

            let view = NavigationStack {
                InsetList {
                    ForEach(groups) { group in
                        IncidentRow(group: group) { group in
                            CrashGroupDetailView(group: group)
                        }
                    }
                }
            }

            assertSnapshot(of: view, as: .scout(height: 220))
            assertSnapshot(of: view, as: .scout(height: 220, style: .dark), named: "dark")
        }

        @Test("Hang groups accented by severity")
        func hangs() {
            guard ViewSnapshot.isSupported else { return }

            let now = Date()
            let entries: [(name: String, duration: TimeInterval, count: Int)] = [
                ("JSON Decode on Main Thread", 4.2, 6),
                ("Image Layout Pass", 9.8, 2),
                ("Watchdog Termination Imminent", 12.5, 1),
            ]

            let groups = zip(entries, Self.offsets).map { entry, offset in
                IncidentGroup(
                    records: (0..<entry.count).map { index in
                        Hang.sample(
                            entry.name,
                            duration: entry.duration,
                            at: now.addingTimeInterval(offset - Double(index)),
                            sessionID: UUID()
                        )
                    }
                )
            }

            let view = NavigationStack {
                InsetList {
                    ForEach(groups) { group in
                        HangRow(group: group)
                    }
                }
            }

            assertSnapshot(of: view, as: .scout(height: 220))
            assertSnapshot(of: view, as: .scout(height: 220, style: .dark), named: "dark")
        }
    }
#endif
