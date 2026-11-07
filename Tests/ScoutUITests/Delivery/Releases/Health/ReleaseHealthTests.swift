//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Testing

@testable import ScoutUI

@Suite("ReleaseHealth")
struct ReleaseHealthTests {
    @Test("The row subtitle joins the adoption share and the ship date")
    func subtitleWithShipDate() throws {
        let release = [ReleaseHealth].samples[0]
        let shippedAt = try #require(release.shippedAt)
        let date = DateFormatter.monthDay.string(from: shippedAt)

        #expect(release.subtitle == "62% of sessions · \(date)")
    }

    @Test("A release without a ship date shows only the adoption share")
    func subtitleWithoutShipDate() {
        #expect(ReleaseHealth.stub(version: "1.0").subtitle == "100% of sessions")
    }
}
