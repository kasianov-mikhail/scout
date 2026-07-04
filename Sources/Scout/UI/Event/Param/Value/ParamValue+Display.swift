//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

extension ParamValue {
    /// Whether the value is a dictionary or an array.
    var isContainer: Bool {
        switch self {
        case .dictionary, .array: true
        case .string, .stringConvertible: false
        }
    }

    /// A one-line digest of the value, used where space is limited.
    var summary: String {
        switch self {
        case .string(let string):
            string
        case .stringConvertible(let convertible):
            convertible.text
        case .dictionary(let entries):
            ExportFormat.counted(entries.count, "pair", "pairs")
        case .array(let values):
            ExportFormat.counted(values.count, "item", "items")
        }
    }

    /// The glyph of the value's kind: an SF Symbol where one fits, literal
    /// text for arrays, which SF Symbols has no bracket glyph for.
    ///
    var icon: Icon {
        switch self {
        case .string: .symbol("textformat")
        case .stringConvertible(let convertible): .symbol(convertible.iconName)
        case .dictionary: .symbol("curlybraces")
        case .array: .text("[ ]")
        }
    }

    /// A kind glyph: either an SF Symbol name or text drawn verbatim.
    enum Icon: Hashable {
        case symbol(String)
        case text(String)
    }
}

extension ParamValue.Convertible {
    /// The verbatim text of the scalar.
    var text: String {
        switch self {
        case .number(let text), .uuid(let text), .url(let text), .date(let text):
            text
        case .boolean(let value):
            value ? "true" : "false"
        }
    }

    /// A short name of the scalar kind, shown in the value badge.
    var label: String {
        switch self {
        case .number: "Number"
        case .boolean: "Boolean"
        case .uuid: "UUID"
        case .url: "URL"
        case .date: "Date"
        }
    }

    /// An SF Symbol of the scalar kind.
    var iconName: String {
        switch self {
        case .number: "number"
        case .boolean(true): "checkmark.circle"
        case .boolean(false): "xmark.circle"
        case .uuid: "tag"
        case .url: "link"
        case .date: "calendar"
        }
    }
}
