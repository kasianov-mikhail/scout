//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import SwiftUI

struct ParamRaw {
    let text: String
    let attributed: AttributedString

    init(text: String) {
        self.text = text
        self.attributed = attributedText(JSONTokenizer.tokens(of: text))
    }

    init(items: [ParamProvider.Item]) {
        var object: [String: Any] = [:]
        for item in items {
            object[item.key] = jsonValue(of: item.value)
        }
        self.init(text: renderJSON(object, indent: 0))
    }
}

private func jsonValue(of fragment: String) -> Any {
    guard let data = fragment.data(using: .utf8) else {
        return fragment
    }
    guard let value = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) else {
        return fragment
    }
    return value
}

private func renderJSON(_ value: Any, indent: Int) -> String {
    let padding = String(repeating: "  ", count: indent)
    let innerPadding = String(repeating: "  ", count: indent + 1)

    switch value {
    case let dictionary as [String: Any]:
        guard !dictionary.isEmpty else {
            return "{}"
        }
        let entries = dictionary.keys.sorted().compactMap { key in
            dictionary[key].map { innerPadding + quoted(key) + ": " + renderJSON($0, indent: indent + 1) }
        }
        return "{\n" + entries.joined(separator: ",\n") + "\n" + padding + "}"
    case let array as [Any]:
        guard !array.isEmpty else {
            return "[]"
        }
        let entries = array.map { innerPadding + renderJSON($0, indent: indent + 1) }
        return "[\n" + entries.joined(separator: ",\n") + "\n" + padding + "]"
    case let string as String:
        return quoted(string)
    case let number as NSNumber:
        return CFGetTypeID(number) == CFBooleanGetTypeID() ? (number.boolValue ? "true" : "false") : number.stringValue
    case is NSNull:
        return "null"
    default:
        return quoted(String(describing: value))
    }
}

private func quoted(_ string: String) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: [string], options: .withoutEscapingSlashes) else {
        return "\"\""
    }
    guard let text = String(data: data, encoding: .utf8) else {
        return "\"\""
    }
    return String(text.dropFirst().dropLast())
}

private func attributedText(_ tokens: [JSONToken]) -> AttributedString {
    tokens.reduce(into: AttributedString()) { result, token in
        var segment = AttributedString(token.text)
        segment.foregroundColor = color(for: token.kind)
        result += segment
    }
}

private func color(for kind: JSONToken.Kind) -> Color {
    switch kind {
    case .key:
        .jsonKey
    case .string:
        .jsonString
    case .number:
        .jsonNumber
    case .literal:
        .jsonLiteral
    case .punctuation, .plain:
        .jsonPunctuation
    }
}
