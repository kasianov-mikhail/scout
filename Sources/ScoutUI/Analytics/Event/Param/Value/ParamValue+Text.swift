//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import ScoutCore

extension ParamValue {
    /// A shareable text form of the value: scalars verbatim, containers as
    /// pretty-printed JSON with sorted keys.
    ///
    var text: String {
        switch self {
        case .string(let string):
            return string
        case .stringConvertible(let convertible):
            return convertible.text
        case .dictionary, .array:
            let options: JSONSerialization.WritingOptions = [.prettyPrinted, .sortedKeys]
            guard let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: options),
                let text = String(data: data, encoding: .utf8)
            else {
                return summary
            }
            return text
        }
    }

    private var jsonObject: Any {
        switch self {
        case .string(let string):
            string
        case .stringConvertible(let convertible):
            convertible.jsonObject
        case .dictionary(let entries):
            Dictionary(uniqueKeysWithValues: entries.map { ($0.key, $0.value.jsonObject) })
        case .array(let values):
            values.map(\.jsonObject)
        }
    }
}

extension ParamValue.Convertible {
    /// The Foundation representation used to rebuild JSON from parsed values.
    fileprivate var jsonObject: Any {
        switch self {
        case .boolean(let value):
            value
        case .number(let text):
            Decimal(string: text).map { NSDecimalNumber(decimal: $0) } ?? text
        case .uuid(let text), .url(let text), .date(let text):
            text
        }
    }
}
