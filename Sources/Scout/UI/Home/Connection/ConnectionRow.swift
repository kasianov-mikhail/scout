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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "circle.fill")
                    .imageScale(.medium)
                    .foregroundStyle(connection.status.healthColor)
                    .accessibilityLabel(Text(verbatim: connection.status.label))
                VStack(spacing: 0) {
                    HStack {
                        Text(verbatim: connection.name).font(.callout)
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
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }
}

#Preview {
    VStack(spacing: 0) {
        ConnectionRow(connection: Connection.samples[0], isActive: true, showsSeparator: true, action: {})
        ConnectionRow(connection: Connection.samples[1], isActive: false, showsSeparator: false, action: {})
    }
    .frame(minWidth: 240)
}

extension Backend.Status {
    fileprivate var label: String {
        switch self {
        case .reachable: "Reachable"
        case .unreachable: "Unreachable"
        case .unknown: "Unknown"
        }
    }
}
