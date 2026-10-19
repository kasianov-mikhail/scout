//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import Scout
import ScoutDB

extension CatalogEntry {
    static let metricSeriesKey = "series_key"

    static let intMetric = metric(entity: IntMetricsEntry.recordType, valueType: .int)
    static let doubleMetric = metric(entity: DoubleMetricsEntry.recordType, valueType: .double)

    static func encodeSeriesKey(category: String, name: String) -> String {
        category.escaped + "|" + name.escaped
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
                return (String(key[..<index]).unescaped, String(key[key.index(after: index)...]).unescaped)
            }
            index = key.index(after: index)
        }
        return nil
    }

    private static func metric(entity: String, valueType: FieldType) -> CatalogEntry {
        CatalogEntry(
            entity: entity,
            fields: [
                .init(name: "name", type: .text),
                .init(name: "category", type: .string),
                .init(name: "session_id", type: .string),
                .init(name: metricSeriesKey, type: .string),
                .init(name: "value", type: valueType),
                .init(name: "date", type: .timestamp),
            ],
            aggregates: [.sum("value", by: metricSeriesKey, at: "date")],
            derive: seriesKey
        )
    }

    private static func seriesKey(for record: Record) -> [String: ScoutDB.RecordValue] {
        let category: String? = record["category"]
        let name: String? = record["name"]
        let key = encodeSeriesKey(category: category ?? "", name: name ?? "")

        return [metricSeriesKey: .string(key)]
    }
}

extension String {
    fileprivate var escaped: String {
        replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "|", with: "\\|")
    }

    fileprivate var unescaped: String {
        var result = ""
        var isEscaped = false
        for character in self {
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
