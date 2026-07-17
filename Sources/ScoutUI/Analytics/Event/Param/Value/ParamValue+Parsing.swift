//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

extension ParamValue {
    /// Parses a raw parameter string into its display classification.
    init(parsing raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        if let structure = Self.structure(from: trimmed) {
            self = structure
        } else if let convertible = Convertible(parsing: trimmed) {
            self = .stringConvertible(convertible)
        } else {
            self = .string(raw)
        }
    }

    private static func structure(from text: String) -> ParamValue? {
        guard text.hasPrefix("{") || text.hasPrefix("[") else {
            return nil
        }
        guard let data = text.data(using: .utf8), let object = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        return value(of: object)
    }

    private static func value(of object: Any) -> ParamValue? {
        switch object {
        case let dictionary as [String: Any]:
            let entries = dictionary.sorted { $0.key < $1.key }.compactMap { pair in
                value(of: pair.value).map { Entry(key: pair.key, value: $0) }
            }
            return .dictionary(entries)
        case let array as [Any]:
            return .array(array.compactMap(value(of:)))
        case let number as NSNumber:
            return number.isBoolean
                ? .stringConvertible(.boolean(number.boolValue))
                : .stringConvertible(.number("\(number)"))
        case let string as String:
            if let convertible = Convertible(parsing: string) {
                return .stringConvertible(convertible)
            }
            return .string(string)
        case is NSNull:
            return .string("null")
        default:
            return nil
        }
    }
}

extension ParamValue.Convertible {
    /// Recognizes a typed scalar from its textual shape, or fails for plain text.
    init?(parsing text: String) {
        if text == "true" || text == "false" {
            self = .boolean(text == "true")
        } else if Self.isNumber(text) {
            self = .number(text)
        } else if UUID(uuidString: text) != nil {
            self = .uuid(text)
        } else if Self.isURL(text) {
            self = .url(text)
        } else if Self.isDate(text) {
            self = .date(text)
        } else {
            return nil
        }
    }

    /// Characters of a decimal or scientific-notation number; excludes look-alikes
    /// that `Double.init` would also accept, such as hex literals or "inf".
    private static let numberScalars = CharacterSet(charactersIn: "0123456789+-.eE")

    private static func isNumber(_ text: String) -> Bool {
        guard text.count > 0, Double(text) != nil else {
            return false
        }
        return text.unicodeScalars.allSatisfy(numberScalars.contains)
    }

    private static func isURL(_ text: String) -> Bool {
        guard let components = URLComponents(string: text) else {
            return false
        }
        return components.scheme != nil && (components.host?.count ?? 0) > 0
    }

    private static func isDate(_ text: String) -> Bool {
        (try? Date(text, strategy: .iso8601)) != nil
            || (try? Date(text, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true))) != nil
    }
}

extension NSNumber {
    /// Whether the number wraps a JSON boolean rather than a numeric value.
    fileprivate var isBoolean: Bool {
        CFGetTypeID(self) == CFBooleanGetTypeID()
    }
}
