//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

enum EntityCatalog {
    static let metricSeriesKey = "series_key"

    static func derivedValues(for record: Record) -> [String: ScoutDB.RecordValue] {
        CatalogEntry.entries.first { $0.entity == record.recordType }?.derive(record) ?? [:]
    }

    static func dateField(for entity: String) -> String {
        switch entity {
        case SessionEntry.recordType, LaunchEntry.recordType:
            "start_date"
        default:
            "date"
        }
    }

    static func encodeSeriesKey(category: String, name: String) -> String {
        escape(category) + "|" + escape(name)
    }

    static func decodeSeriesKey(_ key: String) -> (category: String, name: String)? {
        var isEscaped = false
        var index = key.startIndex
        while index < key.endIndex {
            let character = key[index]
            if isEscaped {
                isEscaped = false
            } else if character == "\\" {
                isEscaped = true
            } else if character == "|" {
                return (unescape(String(key[..<index])), unescape(String(key[key.index(after: index)...])))
            }
            index = key.index(after: index)
        }
        return nil
    }

    private static func escape(_ component: String) -> String {
        component.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "|", with: "\\|")
    }

    private static func unescape(_ escaped: String) -> String {
        var result = ""
        var isEscaped = false
        for character in escaped {
            if isEscaped {
                if character != "\\" && character != "|" {
                    result.append("\\")
                }
                result.append(character)
                isEscaped = false
            } else if character == "\\" {
                isEscaped = true
            } else {
                result.append(character)
            }
        }
        if isEscaped {
            result.append("\\")
        }
        return result
    }
}
