//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ConnectionMenu: View {
    @Binding var activeID: Connection.ID

    @State private var connections: [Connection]
    @State private var isPresented = false

    init(connections: [Connection], activeID: Binding<Connection.ID>) {
        _activeID = activeID
        _connections = State(initialValue: connections)
    }

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "gearshape")
        }
        .popover(isPresented: $isPresented) {
            VStack(spacing: 0) {
                ForEach(connections) { connection in
                    Button {
                        activeID = connection.id
                        isPresented = false
                    } label: {
                        ConnectionRow(
                            connection: connection,
                            isActive: connection.id == activeID,
                            showsSeparator: connection.id != connections.last?.id
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(minWidth: 240)
            .task {
                connections = await connections.refreshingStatuses()
            }
            .popoverDropdown()
            .opaquePresentationBackground()
        }
    }
}

extension View {
    @ViewBuilder func popoverDropdown() -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            presentationCompactAdaptation(.popover)
        } else {
            self
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var activeID = Connection.samples[0].id
    ConnectionMenu(connections: Connection.samples, activeID: $activeID)
}
