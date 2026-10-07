//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension RecordChunk {
    package init(page matches: [Record], limit: Int, after offset: Int = 0) {
        let page = matches.dropFirst(offset).prefix(limit)
        let next = offset + page.count

        self.init(
            records: Array(page),
            cursor: next < matches.count
                ? RecordCursor { _ in RecordChunk(page: matches, limit: limit, after: next) }
                : nil
        )
    }
}
