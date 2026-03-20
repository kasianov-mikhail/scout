//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

struct ChunkedTests {

    @Test("Empty array returns empty result")
    func empty() {
        let result = [Int]().chunked(into: 5)
        #expect(result.isEmpty)
    }

    @Test("Array smaller than chunk size returns single chunk")
    func smallerThanSize() {
        let result = [1, 2, 3].chunked(into: 5)
        #expect(result == [[1, 2, 3]])
    }

    @Test("Array equal to chunk size returns single chunk")
    func equalToSize() {
        let result = [1, 2, 3, 4, 5].chunked(into: 5)
        #expect(result == [[1, 2, 3, 4, 5]])
    }

    @Test("Array larger than chunk size returns multiple chunks")
    func largerThanSize() {
        let result = [1, 2, 3, 4, 5, 6, 7].chunked(into: 3)
        #expect(result == [[1, 2, 3], [4, 5, 6], [7]])
    }

    @Test("Chunk size of 1 returns individual elements")
    func sizeOne() {
        let result = [1, 2, 3].chunked(into: 1)
        #expect(result == [[1], [2], [3]])
    }

    @Test("Exactly divisible array splits evenly")
    func evenSplit() {
        let result = Array(1...9).chunked(into: 3)
        #expect(result == [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
    }
}
