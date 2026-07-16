//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SnapshotTesting
import SwiftUI
import Testing

@testable import Scout

@Suite(.enabled(if: ViewSnapshot.isSupported))
@MainActor struct SegmentBarSnapshotTests {
    @Test("Mixed status breakdown")
    func mixed() {
        guard ViewSnapshot.isSupported else { return }

        let breakdown = StatusBreakdown.sample(
            success: 8140,
            redirect: 210,
            clientError: 96,
            serverError: 18
        )
        assertSnapshot(of: SegmentBar(segments: breakdown.segments).padding(), as: .scout(height: 80))
        assertSnapshot(
            of: SegmentBar(segments: breakdown.segments).padding(),
            as: .scout(height: 80, style: .dark),
            named: "dark"
        )
    }

    @Test("Success only")
    func successOnly() {
        guard ViewSnapshot.isSupported else { return }

        let breakdown = StatusBreakdown.sample(success: 1200)
        assertSnapshot(of: SegmentBar(segments: breakdown.segments).padding(), as: .scout(height: 80))
        assertSnapshot(
            of: SegmentBar(segments: breakdown.segments).padding(),
            as: .scout(height: 80, style: .dark),
            named: "dark"
        )
    }
}
