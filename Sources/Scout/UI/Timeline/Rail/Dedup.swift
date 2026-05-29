//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

func dedup<T: Identifiable>(new: [T], old: [T]) -> [T] where T.ID == CKRecord.ID {
    var seen: Set<CKRecord.ID> = []
    var result: [T] = []
    result.reserveCapacity(new.count + old.count)
    for item in new where seen.insert(item.id).inserted {
        result.append(item)
    }
    for item in old where seen.insert(item.id).inserted {
        result.append(item)
    }
    return result
}
