//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

extension CatalogEntry {
    static let entries: [CatalogEntry] = [
        event,
        screen,
        condition,
        session,
        visit,
        visitGap,
        launch,
        install,
        device,
        version,
        firstSeen,
        retentionMark,
        crash,
        hang,
        resourceException,
        backtrace,
        symbols,
        symbolsFile,
        dailyMetric,
        intMetric,
        doubleMetric,
    ]
}
