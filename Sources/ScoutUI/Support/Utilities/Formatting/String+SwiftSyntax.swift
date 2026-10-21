//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private let keywords: Set<String> = [
    "async", "await", "class", "else", "enum", "extension", "false",
    "func", "if", "import", "init", "let", "nil", "return", "self",
    "struct", "throws", "true", "try", "var",
]

extension String {
    var swiftSyntax: AttributedString {
        var result = AttributedString()
        var index = startIndex

        while index < endIndex {
            let character = self[index]

            if character == "\"" {
                let start = index
                index = self.index(after: index)
                while index < endIndex && self[index] != "\"" {
                    index = self.index(after: index)
                }
                if index < endIndex {
                    index = self.index(after: index)
                }
                var segment = AttributedString(self[start..<index])
                segment.foregroundColor = .red
                result += segment
            } else if character.isLetter || character == "_" {
                let start = index
                while index < endIndex,
                    self[index].isLetter || self[index].isNumber || self[index] == "_"
                {
                    index = self.index(after: index)
                }
                let word = String(self[start..<index])
                var segment = AttributedString(word)
                if keywords.contains(word) {
                    segment.foregroundColor = .pink
                } else if word.first?.isUppercase == true {
                    segment.foregroundColor = .purple
                }
                result += segment
            } else {
                result += AttributedString(String(character))
                index = self.index(after: index)
            }
        }

        return result
    }
}
