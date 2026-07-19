//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class FilterDraft: ObservableObject {
    private let query: Binding<EventQuery>

    @Published var levels: Set<EventLevel>
    @Published var isDateRangeEnabled: Bool
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var sessionText: String
    @Published var deviceText: String

    private let defaultStartDate: Date
    private let defaultEndDate: Date

    init(query: Binding<EventQuery>, today: Date = Date()) {
        let value = query.wrappedValue
        let start = today.startOfDay.addingDay(-6)
        let end = today.startOfDay

        self.query = query
        self.defaultStartDate = start
        self.defaultEndDate = end
        self.levels = value.levels
        self.isDateRangeEnabled = value.dates != nil
        self.startDate = value.dates?.lowerBound ?? start
        self.endDate = value.dates.map { $0.upperBound.addingDay(-1) } ?? end
        self.sessionText = value.sessionID?.uuidString ?? ""
        self.deviceText = value.deviceID?.uuidString ?? ""
    }
}

extension FilterDraft {
    func isSelected(_ level: EventLevel) -> Bool {
        levels.contains(level)
    }

    func toggle(_ level: EventLevel) {
        levels.formSymmetricDifference([level])
    }
}

extension FilterDraft {
    var sessionID: UUID? {
        UUID(uuidString: sessionText.trimmed)
    }

    var deviceID: UUID? {
        UUID(uuidString: deviceText.trimmed)
    }

    var isSessionValid: Bool {
        sessionText.trimmed.isEmpty || sessionID != nil
    }

    var isDeviceValid: Bool {
        deviceText.trimmed.isEmpty || deviceID != nil
    }

    var isDateRangeValid: Bool {
        !isDateRangeEnabled || startDate.startOfDay <= endDate.startOfDay
    }
}

extension FilterDraft {
    var result: EventQuery {
        var result = query.wrappedValue
        result.levels = levels
        result.dates = isDateRangeEnabled ? startDate.startOfDay..<endDate.startOfDay.addingDay() : nil
        result.sessionID = sessionID
        result.deviceID = deviceID
        return result
    }

    var isApplyEnabled: Bool {
        levels.count > 0 && isSessionValid && isDeviceValid && isDateRangeValid && result != query.wrappedValue
    }

    func apply() {
        query.wrappedValue = result
    }
}

extension FilterDraft {
    var isResetEnabled: Bool {
        levels != EventQuery.allLevels || isDateRangeEnabled || sessionText.trimmed.count > 0
            || deviceText.trimmed.count > 0
    }

    func reset() {
        levels = EventQuery.allLevels
        isDateRangeEnabled = false
        startDate = defaultStartDate
        endDate = defaultEndDate
        sessionText = ""
        deviceText = ""
    }
}

extension String {
    fileprivate var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
