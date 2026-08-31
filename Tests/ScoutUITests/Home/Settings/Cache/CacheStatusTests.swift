//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import ScoutUI

@MainActor
@Suite("CacheStatus")
struct CacheStatusTests {
    @Test("Clearing empties the cache")
    func clears() {
        let status = CacheStatus(bytes: 4_096)

        status.clear()

        #expect(status.bytes == 0)
        #expect(status.isEmpty)
    }

    @Test("An empty cache reads as empty rather than as zero bytes")
    func labelsAnEmptyCache() {
        let status = CacheStatus(bytes: 0)

        #expect(status.isEmpty)
        #expect(status.sizeLabel == "Empty")
    }

    @Test("A populated cache reports its size in file units")
    func labelsAPopulatedCache() {
        let status = CacheStatus(bytes: 12_582_912)

        #expect(!status.isEmpty)
        #expect(status.sizeLabel == Int64(12_582_912).formatted(.byteCount(style: .file)))
    }

    @Test("A larger cache reads differently from a smaller one")
    func labelsScaleWithSize() {
        #expect(CacheStatus(bytes: 12_582_912).sizeLabel != CacheStatus(bytes: 12_288).sizeLabel)
    }
}
