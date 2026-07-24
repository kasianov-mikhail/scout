//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Backend {
    /// A self-contained demo backend backed by a local, offline database that is
    /// preloaded with fabricated data covering every dashboard screen.
    ///
    /// Nothing here touches the network or iCloud: the returned backend reports
    /// itself reachable and answers every query from an in-memory corpus, so it
    /// can drive `scoutHome(isPresented:backends:)` for previews, screenshots,
    /// and App Store demos.
    ///
    /// - Parameter now: The reference moment to generate the corpus relative to. Passing `nil` reuses the
    ///   shared corpus built for the current date, so repeated calls don't rebuild it.
    /// - Returns: A `Backend` whose database is a seeded ``DemoDatabase``.
    ///
    public static func demo(now: Date? = nil) -> Backend {
        Backend(
            id: "scout.demo",
            database: DemoDatabase(corpus: now.map(DemoCorpus.make(now:)) ?? DemoCorpus.shared),
            checkAvailability: { true },
            displayName: "Demo",
            engine: .local,
            probeStatus: { .reachable }
        )
    }
}
