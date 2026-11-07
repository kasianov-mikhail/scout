//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

struct ReleaseHealthTests {
    @Test("The adoption label pairs the share with the ship date")
    func adoptionLabelWithDate() {
        let release = ReleaseHealth.stub(version: "1.0", shipped: Date(timeIntervalSince1970: 0))

        #expect(release.adoptionLabel == "100% of sessions · Jan 1")
    }

    @Test("The adoption label omits a missing ship date")
    func adoptionLabelWithoutDate() {
        let release = ReleaseHealth.stub(version: "1.0")

        #expect(release.adoptionLabel == "100% of sessions")
    }
}
