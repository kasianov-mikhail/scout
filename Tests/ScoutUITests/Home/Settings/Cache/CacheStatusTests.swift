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
    @Test("The status reports the size the storage measures")
    func reportsStorageSize() {
        #expect(CacheStatus(storage: makeStorage(size: 4_096)).bytes == 4_096)
    }

    @Test("Clearing erases the storage and measures it again")
    func clears() {
        var size: Int64 = 4_096
        var clears = 0
        let storage = CacheStorage(
            bytes: { size },
            removeAll: {
                clears += 1
                size = 0
            }
        )
        let status = CacheStatus(storage: storage)

        status.clear()

        #expect(clears == 1)
        #expect(status.bytes == 0)
        #expect(status.isEmpty)
    }

    @Test("An empty cache reads as empty rather than as zero bytes")
    func labelsAnEmptyCache() {
        let status = CacheStatus(storage: makeStorage(size: 0))

        #expect(status.isEmpty)
        #expect(status.sizeLabel == "Empty")
    }

    @Test("A populated cache reports its size in file units")
    func labelsAPopulatedCache() {
        let status = CacheStatus(storage: makeStorage(size: 12_582_912))

        #expect(!status.isEmpty)
        #expect(status.sizeLabel == Int64(12_582_912).formatted(.byteCount(style: .file)))
    }

    @Test("A larger cache reads differently from a smaller one")
    func labelsScaleWithSize() {
        let large = CacheStatus(storage: makeStorage(size: 12_582_912))
        let small = CacheStatus(storage: makeStorage(size: 12_288))

        #expect(large.sizeLabel != small.sizeLabel)
    }
}

@MainActor
private func makeStorage(size: Int64) -> CacheStorage {
    CacheStorage(bytes: { size }, removeAll: {})
}
