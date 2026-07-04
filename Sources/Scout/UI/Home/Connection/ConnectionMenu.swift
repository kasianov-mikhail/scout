//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ConnectionMenu: View {
    @Binding var activeID: Connection.ID
    let onSettings: () -> Void

    @State private var connections: [Connection]
    @State private var isPresented = false
    @State private var opensSettingsAfterDismiss = false

    init(connections: [Connection], activeID: Binding<Connection.ID>, onSettings: @escaping () -> Void = {}) {
        _activeID = activeID
        self.onSettings = onSettings
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
                            showsSeparator: true
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    opensSettingsAfterDismiss = true
                    isPresented = false
                } label: {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .imageScale(.medium)
                            .foregroundStyle(.secondary)
                        Text(verbatim: "Settings")
                            .font(.system(size: 16))
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .frame(minWidth: 240)
            .task {
                connections = await connections.refreshingStatuses()
            }
            .popoverDropdown()
            .opaquePresentationBackground()
        }
        .onChange(of: isPresented) { isPresented in
            guard !isPresented, opensSettingsAfterDismiss else { return }

            opensSettingsAfterDismiss = false
            onSettings()
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
