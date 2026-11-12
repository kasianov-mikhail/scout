//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ConnectionMenu: View {
    @Binding var activeID: Connection.ID

    let onSettings: (() -> Void)?

    @State private var connections: [Connection]
    @State private var isPresented = false

    init(connections: [Connection], activeID: Binding<Connection.ID>, onSettings: (() -> Void)? = nil) {
        _activeID = activeID
        _connections = State(initialValue: connections)
        self.onSettings = onSettings
    }

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "server.rack")
        }
        .foregroundStyle(.primary)
        .accessibilityLabel(Text(verbatim: "Backend"))
        .popover(isPresented: $isPresented) {
            VStack(spacing: 0) {
                ForEach(connections) { connection in
                    ConnectionRow(
                        connection: connection,
                        isActive: connection.id == activeID,
                        showsSeparator: connection.id != connections.last?.id
                    ) {
                        activeID = connection.id
                        isPresented = false
                    }
                }

                if let onSettings {
                    Button {
                        isPresented = false
                        Task { @MainActor in
                            try? await Task.sleep(for: .milliseconds(250))
                            onSettings()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "gearshape")
                            Text(verbatim: "Settings")
                            Spacer(minLength: 0)
                        }
                        .font(.book(size: 16))
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .overlay(alignment: .top) {
                        Separator()
                    }
                }
            }
            .padding(.vertical, 8)
            .frame(minWidth: 240)
            .hapticFeedback(.selection, trigger: activeID)
            .task {
                connections = await connections.refreshingStatuses()
            }
            .popoverDropdown()
            .opaquePresentation()
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
    @Previewable @State var activeID = [Connection].samples[0].id
    ConnectionMenu(connections: .samples, activeID: $activeID)
}
