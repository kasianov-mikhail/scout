//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension TimelineRowsBuilder {
    static func group<Element>(_ elements: [Element], by keyPath: KeyPath<Element, UUID?>) -> [UUID: [Element]] {
        var result: [UUID: [Element]] = [:]
        for element in elements {
            guard let id = element[keyPath: keyPath] else {
                continue
            }
            result[id, default: []].append(element)
        }
        return result
    }

    static func bounds(for starts: [Date]) -> [Date: Date] {
        var result: [Date: Date] = [:]
        var next: Date?
        for start in Set(starts).sorted(by: >) {
            if let next {
                result[start] = next
            }
            next = start
        }
        return result
    }

    static func range(for starts: [Date]) -> ClosedRange<Date>? {
        guard let lower = starts.min(), let upper = starts.max() else {
            return nil
        }
        return lower...upper
    }

    static func versions(_ versions: [Version]) -> [UUID: String] {
        var result: [UUID: String] = [:]
        for version in versions.sorted(byDate: \.date) {
            guard let launchID = version.launchID, let appVersion = version.appVersion else {
                continue
            }
            result[launchID] = appVersion
        }
        return result
    }
}
