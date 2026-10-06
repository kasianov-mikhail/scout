//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

extension SeriesTotals {
    init(points: [SeriesPoint], bucket: SeriesBucket, key: (String) -> SeriesKey?) {
        self.init()

        for point in points {
            guard let key = key(point.group) else {
                continue
            }

            add(point.value, key: key, date: point.date, bucket: bucket)
        }
    }
}
