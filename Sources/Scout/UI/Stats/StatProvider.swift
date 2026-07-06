//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

class StatProvider: QueryProvider<GridMatrix<Int>> {
    let eventName: String
    let periods: [Period]

    init(eventName: String, periods: [Period]) {
        self.eventName = eventName
        self.periods = periods

        super.init {
            RecordQuery(
                recordType: GridMatrix<Int>.self,
                filters: Calendar.utc.defaultRange.dateFilters + [
                    RecordQuery.Filter(field: "name", op: .equals, value: .string(eventName))
                ]
            )
        }
    }
}

extension StatProvider {
    static func fixture(eventName: String) -> StatProvider {
        let provider = StatProvider(eventName: eventName, periods: Period.summary)
        provider.result = .success([.sample(name: eventName)])
        return provider
    }
}
