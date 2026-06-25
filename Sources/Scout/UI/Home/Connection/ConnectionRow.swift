//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ConnectionRow: View {
    let connection: Connection
    let isActive: Bool
    let showsSeparator: Bool

    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .imageScale(.medium)
                .foregroundStyle(connection.status.color)
                .accessibilityLabel(Text(verbatim: connection.status.label))
            VStack(spacing: 0) {
                HStack {
                    Text(verbatim: connection.name).font(.system(size: 16))
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 12)

                if showsSeparator {
                    Divider()
                }
            }
            .padding(.trailing, 16)
        }
        .padding(.leading, 16)
        .background {
            if isActive {
                Rectangle().fill(.tint.opacity(0.12))
            }
        }
        .contentShape(Rectangle())
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }
}

extension Backend.Status {
    fileprivate var label: String {
        switch self {
        case .reachable: "Reachable"
        case .unreachable: "Unreachable"
        case .unknown: "Unknown"
        }
    }

    fileprivate var color: Color {
        switch self {
        case .reachable: .green
        case .unreachable: .red
        case .unknown: .gray
        }
    }
}
