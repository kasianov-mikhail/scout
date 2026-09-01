//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

@MainActor
@Suite("CacheStatus")
struct CacheStatusTests {
    @Test("The status has no size until it is refreshed")
    func startsUnmeasured() {
        let status = CacheStatus(cache: SpyCacheClearing(size: 4_096))

        #expect(status.bytes == nil)
        #expect(!status.isEmpty)
        #expect(status.sizeLabel == "")
    }

    @Test("Refreshing reports the size the storage measures")
    func reportsStorageSize() async {
        #expect(await makeStatus(size: 4_096).bytes == 4_096)
    }

    @Test("Clearing erases the storage and measures it again")
    func clears() async {
        let cache = SpyCacheClearing(size: 4_096)
        let status = CacheStatus(cache: cache)

        await status.clear()

        #expect(await cache.clears == 1)
        #expect(status.bytes == 0)
        #expect(status.isEmpty)
    }

    @Test("An empty cache reads as empty rather than as zero bytes")
    func labelsAnEmptyCache() async {
        let status = await makeStatus(size: 0)

        #expect(status.isEmpty)
        #expect(status.sizeLabel == "Empty")
    }

    @Test("A populated cache reports its size in file units")
    func labelsAPopulatedCache() async {
        let status = await makeStatus(size: 12_582_912)

        #expect(!status.isEmpty)
        #expect(status.sizeLabel == Int64(12_582_912).formatted(.byteCount(style: .file)))
    }

    @Test("A larger cache reads differently from a smaller one")
    func labelsScaleWithSize() async {
        let large = await makeStatus(size: 12_582_912)
        let small = await makeStatus(size: 12_288)

        #expect(large.sizeLabel != small.sizeLabel)
    }
}

@MainActor
private func makeStatus(size: Int64) async -> CacheStatus {
    let status = CacheStatus(cache: SpyCacheClearing(size: size))
    await status.refresh()
    return status
}

private actor SpyCacheClearing: CacheClearing {
    private(set) var size: Int64
    private(set) var clears = 0

    init(size: Int64) {
        self.size = size
    }

    func removeAll() {
        clears += 1
        size = 0
    }
}
