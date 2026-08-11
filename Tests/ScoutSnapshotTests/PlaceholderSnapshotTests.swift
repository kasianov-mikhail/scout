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
    @MainActor struct PlaceholderSnapshotTests {
        @Test("Text only")
        func text() {
            guard ViewSnapshot.isSupported else { return }

            let view = Placeholder(text: "No results")

            assertSnapshot(of: view, as: .scout(height: 200))
            assertSnapshot(of: view, as: .scout(height: 200, style: .dark), named: "dark")
        }

        @Test("Icon and description")
        func described() {
            guard ViewSnapshot.isSupported else { return }

            let view = Placeholder(
                text: "No crashes",
                systemImage: "checkmark.shield",
                description: "No crash reports have been recorded"
            )

            assertSnapshot(of: view, as: .scout(height: 260))
            assertSnapshot(of: view, as: .scout(height: 260, style: .dark), named: "dark")
        }

        @Test("Code chip")
        func code() {
            guard ViewSnapshot.isSupported else { return }

            let view = Placeholder(
                text: "No results",
                systemImage: "list.bullet",
                description: "Events will appear here once your app starts logging",
                code: "logger.info(\"button_tapped\")"
            )

            assertSnapshot(of: view, as: .scout(height: 320))
            assertSnapshot(of: view, as: .scout(height: 320, style: .dark), named: "dark")
        }
    }
#endif
