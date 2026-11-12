//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct IncidentStackView: View {
    let stack: IncidentStack
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(stack.rows) { row in
                IncidentStackRowView(row: row, isCulprit: stack.culprit?.id == row.id, color: color)
            }
        }
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}

private struct IncidentStackRowView: View {
    let row: IncidentStackRow
    let isCulprit: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Text(verbatim: "\(row.id)")
                .frame(width: 18, alignment: .leading)

            Text(verbatim: row.image)
                .frame(width: 128, alignment: .leading)

            Text(verbatim: row.symbol ?? "")

            Spacer(minLength: 0)
        }
        .font(.weighted(size: 12, weight: weight, design: .monospaced))
        .foregroundStyle(foreground)
        .lineLimit(1)
        .frame(height: .codeStep)
        .accessibilityElement(children: .combine)
    }

    private var weight: Font.Weight {
        if isCulprit {
            return .bold
        }
        if row.location != nil {
            return .semibold
        }
        return .regular
    }

    private var foreground: Color {
        if isCulprit {
            return color
        }
        if row.location != nil {
            return .primary
        }
        return Color(.systemGray)
    }
}
