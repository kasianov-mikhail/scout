//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

/// The colored kind icon of a value.
struct ParamIcon: View {
    let value: ParamValue

    var body: some View {
        Group {
            switch value.icon {
            case .symbol(let name):
                Image(systemName: name)
                    .font(.fixedBody)
            case .text(let text):
                Text(text)
                    .font(.fixedBody.weight(.semibold))
                    .fixedSize()
            }
        }
        .foregroundStyle(value.color)
        .frame(width: 24)
    }
}

/// A capsule naming the recognized scalar kind.
struct ParamBadge: View {
    let convertible: ParamValue.Convertible

    var body: some View {
        Label(convertible.label, systemImage: convertible.iconName)
            .font(.fixedCaption.weight(.medium))
            .foregroundStyle(convertible.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(convertible.color.opacity(0.13), in: Capsule())
    }
}

extension ParamValue {
    /// The accent color of the value's kind.
    var color: Color {
        switch self {
        case .string: .primary
        case .stringConvertible(let convertible): convertible.color
        case .dictionary: .indigo
        case .array: .brown
        }
    }
}

extension ParamValue.Convertible {
    /// The accent color of the scalar kind.
    var color: Color {
        switch self {
        case .number: .blue
        case .boolean(true): .green
        case .boolean(false): .red
        case .uuid: .purple
        case .url: .teal
        case .date: .orange
        }
    }
}
