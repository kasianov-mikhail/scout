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

enum EntityCatalog {
    static let metricSeriesKey = "series_key"

    static func derivedValues(for record: Record) -> [String: ScoutDB.RecordValue] {
        CatalogEntry.entries.first { $0.entity == record.recordType }?.derive(record) ?? [:]
    }

    static func assetFields(entity: String) -> [String] {
        let fields = CatalogEntry.entries.first { $0.entity == entity }?.fields ?? []
        return fields.filter { $0.type == .asset }.map(\.name)
    }

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
