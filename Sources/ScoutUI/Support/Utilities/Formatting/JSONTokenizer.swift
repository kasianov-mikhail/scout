//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct JSONToken: Equatable {
    enum Kind: Equatable {
        case key
        case string
        case number
        case literal
        case punctuation
        case plain
    }

    let kind: Kind
    let text: String
}

enum JSONTokenizer {
    static func tokens(of source: String) -> [JSONToken] {
        guard source.utf8.count <= maxHighlightedBytes else {
            return [JSONToken(kind: .plain, text: source)]
        }
        guard isValid(source) else {
            return [JSONToken(kind: .plain, text: source)]
        }
        return scan(source)
    }
}

private let maxHighlightedBytes = 100_000

private func isValid(_ source: String) -> Bool {
    guard let data = source.data(using: .utf8) else {
        return false
    }
    return (try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)) != nil
}

private func scan(_ source: String) -> [JSONToken] {
    var tokens: [JSONToken] = []
    var index = source.startIndex

    while index < source.endIndex {
        let character = source[index]

        if character == "\"" {
            let start = index
            index = source.index(after: index)
            while index < source.endIndex {
                if source[index] == "\\" {
                    index = source.index(after: index)
                    if index < source.endIndex {
                        index = source.index(after: index)
                    }
                } else if source[index] == "\"" {
                    index = source.index(after: index)
                    break
                } else {
                    index = source.index(after: index)
                }
            }
            var cursor = index
            while cursor < source.endIndex, source[cursor].isWhitespace {
                cursor = source.index(after: cursor)
            }
            let isKey = cursor < source.endIndex && source[cursor] == ":"
            tokens.append(JSONToken(kind: isKey ? .key : .string, text: String(source[start..<index])))
        } else if character == "-" || character.isNumber {
            let start = index
            index = source.index(after: index)
            while index < source.endIndex, source[index].isNumber {
                index = source.index(after: index)
            }
            if index < source.endIndex, source[index] == "." {
                index = source.index(after: index)
                while index < source.endIndex, source[index].isNumber {
                    index = source.index(after: index)
                }
            }
            if index < source.endIndex, source[index] == "e" || source[index] == "E" {
                index = source.index(after: index)
                if index < source.endIndex, source[index] == "+" || source[index] == "-" {
                    index = source.index(after: index)
                }
                while index < source.endIndex, source[index].isNumber {
                    index = source.index(after: index)
                }
            }
            tokens.append(JSONToken(kind: .number, text: String(source[start..<index])))
        } else if character.isLetter {
            let start = index
            while index < source.endIndex, source[index].isLetter {
                index = source.index(after: index)
            }
            let word = source[start..<index]
            let kind: JSONToken.Kind = word == "true" || word == "false" || word == "null" ? .literal : .plain
            tokens.append(JSONToken(kind: kind, text: String(word)))
        } else if "{}[]:,".contains(character) {
            tokens.append(JSONToken(kind: .punctuation, text: String(character)))
            index = source.index(after: index)
        } else {
            let start = index
            while index < source.endIndex, !isTokenStart(source[index]) {
                index = source.index(after: index)
            }
            tokens.append(JSONToken(kind: .plain, text: String(source[start..<index])))
        }
    }

    return tokens
}

private func isTokenStart(_ character: Character) -> Bool {
    character == "\""
        || character == "-"
        || character.isNumber
        || character.isLetter
        || "{}[]:,".contains(character)
}
