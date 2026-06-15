//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// A toolbar gear that drops down the list of servers to read from.
///
/// Each server carries a reachability dot — green reachable, red unreachable,
/// grey unknown — and the active one is checkmarked. Presented as a `popover`
/// rather than a system `Menu`, whose glyphs render monochrome and would
/// flatten the status dots.
///
struct DataSourceMenu: View {
    let servers: [BackendOption]
    @Binding var activeID: BackendOption.ID

    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "gearshape")
        }
        .popover(isPresented: $isPresented) {
            DataSourceList(servers: servers, activeID: $activeID, isPresented: $isPresented)
                .popoverDropdown()
        }
    }
}

/// The server rows shown inside the ``DataSourceMenu`` dropdown.
private struct DataSourceList: View {
    let servers: [BackendOption]
    @Binding var activeID: BackendOption.ID
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            ForEach(servers) { server in
                Button {
                    activeID = server.id
                    isPresented = false
                } label: {
                    ServerRow(server: server, isActive: server.id == activeID)
                }
                .buttonStyle(.plain)

                if server.id != servers.last?.id {
                    Divider()
                }
            }
        }
        .frame(minWidth: 240)
    }
}

/// One server line: status dot, name and host, and an active checkmark.
private struct ServerRow: View {
    let server: BackendOption
    let isActive: Bool

    var body: some View {
        HStack(spacing: 10) {
            StatusDot(status: server.status)
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: server.name)
                Text(verbatim: server.host)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 16)
            Image(systemName: "checkmark")
                .fontWeight(.semibold)
                .foregroundStyle(.tint)
                .opacity(isActive ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

extension View {
    /// Keeps the popover a dropdown in compact widths where it would otherwise
    /// adapt into a sheet (iOS 16.4+; a no-op on earlier systems).
    ///
    @ViewBuilder func popoverDropdown() -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            presentationCompactAdaptation(.popover)
        } else {
            self
        }
    }
}

// MARK: - Previews

private struct DataSourceMenuPreview: View {
    @State private var activeID = BackendOption.samples[0].id

    var body: some View {
        NavigationStack {
            Text(verbatim: "Home")
                .navigationTitle(en: "Home")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        DataSourceMenu(servers: BackendOption.samples, activeID: $activeID)
                    }
                }
        }
    }
}

#Preview("Toolbar") {
    DataSourceMenuPreview()
}

#Preview("Dropdown") {
    StatefulDropdownPreview()
}

private struct StatefulDropdownPreview: View {
    @State private var activeID = BackendOption.samples[0].id
    @State private var isPresented = true

    var body: some View {
        DataSourceList(servers: BackendOption.samples, activeID: $activeID, isPresented: $isPresented)
            .padding(.vertical, 4)
    }
}
