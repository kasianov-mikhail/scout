//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension ActivityPoint: Fixture {
    static var samples: [ActivityPoint] {
        let end = Date().startOfDay
        let recent = [
            1017, 1099, 1139, 1085, 977, 1126, 1194, 1058, 1153, 1207,
            1126, 1017, 1166, 1234, 1112, 1180, 1248, 1194, 1058, 1207,
            1261, 1144, 1198, 1284, 1226, 1102, 1240, 1302, 1181, 1212,
        ]
        var older = (0..<336).map { index in
            900 + index * 264 / 335 + index % 7 * 3 - 9
        }
        older[335] = 1_164
        let daily = older + recent

        return daily.enumerated().reversed().map { index, dau in
            ActivityPoint(
                date: end.addingDay(index - 365).millisecondsSince1970,
                dau: dau,
                wau: index == 365 ? 4_980 : (index == 335 || index == 364) ? 4_854 : Int(Double(dau) * 4.1),
                mau: index == 365 ? 14_300 : (index == 335 || index == 364) ? 14_187 : Int(Double(dau) * 11.8)
            )
        }
    }
}
