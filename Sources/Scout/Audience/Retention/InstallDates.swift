//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct InstallDates {
    let install: String
    let dates: Set<Date>
}

extension [InstallDates] {
    init(_ dated: [DatedID]) {
        self = Dictionary(grouping: dated, by: \.id).map {
            InstallDates(
                install: $0.key,
                dates: Set($0.value.map(\.date))
            )
        }
    }

    func dates(of install: String) -> Set<Date> {
        first { $0.install == install }?.dates ?? []
    }
}
