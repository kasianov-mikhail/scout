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
    private let today: Date

    @Published var levels: Set<EventLevel>
    @Published var period: FilterPeriod
    @Published var sessionText: String
    @Published var deviceText: String

    init(query: Binding<EventQuery>, today: Date = Date()) {
        let value = query.wrappedValue

        self.query = query
        self.today = today.startOfDay
        self.levels = value.levels == EventQuery.allLevels ? [] : value.levels
        self.period = FilterPeriod(dates: value.dates, today: today)
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
}

extension FilterDraft {
    var result: EventQuery {
        var result = query.wrappedValue
        result.levels = levels.isEmpty ? EventQuery.allLevels : levels
        result.dates = period.dates(today: today)
        result.sessionID = sessionID
        result.deviceID = deviceID
        return result
    }

    var isApplyEnabled: Bool {
        isSessionValid && isDeviceValid && result != query.wrappedValue
    }

    func apply() {
        query.wrappedValue = result
    }

    func reset() {
        levels = []
        period = .any
        sessionText = ""
        deviceText = ""
    }
}

enum FilterPeriod: Hashable, Identifiable {
    case any
    case today
    case week
    case month
    case custom(Range<Date>)

    static let presets = [FilterPeriod.any, .today, .week, .month]

    var id: Self { self }

    var title: String {
        switch self {
        case .any:
            "Any"
        case .today:
            "Today"
        case .week:
            "7 days"
        case .month:
            "30 days"
        case .custom:
            "Custom"
        }
    }

    init(dates: Range<Date>?, today: Date) {
        guard let dates else {
            self = .any
            return
        }
        self = FilterPeriod.presets.first { $0.dates(today: today) == dates } ?? .custom(dates)
    }

    func dates(today: Date) -> Range<Date>? {
        let end = today.startOfDay.addingDay()

        return switch self {
        case .any:
            nil
        case .today:
            end.addingDay(-1)..<end
        case .week:
            end.addingDay(-7)..<end
        case .month:
            end.addingDay(-30)..<end
        case .custom(let dates):
            dates
        }
    }
}

extension String {
    fileprivate var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
