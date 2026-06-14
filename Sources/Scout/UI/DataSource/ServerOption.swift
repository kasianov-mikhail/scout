//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// Reachability of a data source, mirroring a backend's `checkAvailability`.
enum ServerStatus: CaseIterable, Identifiable {
    case reachable
    case unreachable
    case unknown

    var id: Self { self }

    var label: String {
        switch self {
        case .reachable: "Reachable"
        case .unreachable: "Unreachable"
        case .unknown: "Unknown"
        }
    }

    var color: Color {
        switch self {
        case .reachable: .green
        case .unreachable: .red
        case .unknown: .gray
        }
    }
}

/// A server the user can pick as the source reads go to.
///
/// Presentation-only: it mirrors the fields a ``Backend`` exposes to the UI —
/// a display name, the host it talks to, and current reachability — without
/// owning the live connection.
///
struct ServerOption: Identifiable {
    let id: UUID
    var name: String
    var host: String
    var status: ServerStatus

    init(id: UUID = UUID(), name: String, host: String, status: ServerStatus) {
        self.id = id
        self.name = name
        self.host = host
        self.status = status
    }
}

// MARK: - Sample

extension ServerOption {
    static var sample: ServerOption {
        ServerOption(name: "Production", host: "api.scout.app", status: .reachable)
    }

    static var samples: [ServerOption] {
        [
            ServerOption(name: "Production", host: "api.scout.app", status: .reachable),
            ServerOption(name: "Staging", host: "staging.scout.app", status: .unknown),
            ServerOption(name: "Local", host: "localhost:8080", status: .unreachable),
        ]
    }
}
