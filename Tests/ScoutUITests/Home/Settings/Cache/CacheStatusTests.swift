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
    @Test("The status reports the size the storage measures once loaded")
    func reportsStorageSize() async {
        let status = CacheStatus(storage: makeStorage(size: 4_096))
        #expect(status.bytes == 0)

        await status.load()

        #expect(status.bytes == 4_096)
    }

    @Test("Clearing erases the storage and measures it again")
    func clears() async {
        let fake = makeStorage(size: 4_096)
        let status = CacheStatus(storage: fake)
        await status.load()

        await status.clear()

        #expect(await fake.clears == 1)
        #expect(status.bytes == 0)
        #expect(status.isEmpty)
    }

    @Test("An empty cache reads as empty rather than as zero bytes")
    func labelsAnEmptyCache() async {
        let status = CacheStatus(storage: makeStorage(size: 0))
        await status.load()

        #expect(status.isEmpty)
        #expect(status.sizeLabel == "Empty")
    }

    @Test("A populated cache reports its size in file units")
    func labelsAPopulatedCache() async {
        let status = CacheStatus(storage: makeStorage(size: 12_582_912))
        await status.load()

        #expect(!status.isEmpty)
        #expect(status.sizeLabel == Int64(12_582_912).formatted(.byteCount(style: .file)))
    }

    @Test("A larger cache reads differently from a smaller one")
    func labelsScaleWithSize() async {
        let large = CacheStatus(storage: makeStorage(size: 12_582_912))
        let small = CacheStatus(storage: makeStorage(size: 12_288))
        await large.load()
        await small.load()

        #expect(large.sizeLabel != small.sizeLabel)
    }
}

private func makeStorage(size: Int64) -> FakeCacheStorage {
    FakeCacheStorage(bytes: size)
}

private actor FakeCacheStorage: CacheStorage {
    private(set) var clears = 0
    private var size: Int64

    init(bytes: Int64) {
        self.size = bytes
    }

    func bytes() -> Int64 {
        size
    }

    func removeAll() {
        clears += 1
        size = 0
    }
}
