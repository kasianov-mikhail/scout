//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

extension ParamValue {
    var isContainer: Bool {
        switch self {
        case .dictionary, .array: true
        case .string, .stringConvertible: false
        }
    }

    var summary: String {
        switch self {
        case .string(let string):
            string
        case .stringConvertible(let convertible):
            convertible.text
        case .dictionary(let entries):
            ExportFormat.counted(entries.count, .pair)
        case .array(let values):
            ExportFormat.counted(values.count, .item)
        }
    }

    var icon: Icon {
        switch self {
        case .string:
            .symbol("textformat")
        case .stringConvertible(let convertible):
            .symbol(convertible.iconName)
        case .dictionary:
            .symbol("curlybraces")
        case .array:
            .text("[ ]")
        }
    }

    enum Icon: Hashable {
        case symbol(String)
        case text(String)
    }

    var color: Color {
        switch self {
        case .string:
            .primary
        case .stringConvertible(let convertible):
            convertible.color
        case .dictionary:
            .indigo
        case .array:
            .brown
        }
    }
}

extension ParamValue.Convertible {
    var text: String {
        switch self {
        case .number(let text), .uuid(let text), .url(let text), .date(let text):
            text
        case .boolean(let value):
            value ? "true" : "false"
        }
    }

    var label: String {
        switch self {
        case .number:
            "Number"
        case .boolean:
            "Boolean"
        case .uuid:
            "UUID"
        case .url:
            "URL"
        case .date:
            "Date"
        }
    }

    var iconName: String {
        switch self {
        case .number:
            "number"
        case .boolean(true):
            "checkmark.circle"
        case .boolean(false):
            "xmark.circle"
        case .uuid:
            "tag"
        case .url:
            "link"
        case .date:
            "calendar"
        }
    }

    var color: Color {
        switch self {
        case .number:
            .blue
        case .boolean(true):
            .green
        case .boolean(false):
            .red
        case .uuid:
            .purple
        case .url:
            .teal
        case .date:
            .orange
        }
    }
}
