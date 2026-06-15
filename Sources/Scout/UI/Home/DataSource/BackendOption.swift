//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension BackendStatus {
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
/// a stable identity, a display name, the host it talks to, and current
/// reachability — without owning the live connection. The `id` is the
/// backend's own stable identifier (its container identifier or server URL),
/// so a selection survives reordering or re-resolving the backend list.
///
struct BackendOption: Identifiable {
    let id: String
    var name: String
    var host: String
    var status: BackendStatus
}

// MARK: - Sample

extension BackendOption {
    static var sample: BackendOption {
        BackendOption(id: "https://api.scout.app", name: "Production", host: "api.scout.app", status: .reachable)
    }

    static var samples: [BackendOption] {
        [
            BackendOption(id: "https://api.scout.app", name: "Production", host: "api.scout.app", status: .reachable),
            BackendOption(id: "https://staging.scout.app", name: "Staging", host: "staging.scout.app", status: .unknown),
            BackendOption(id: "http://localhost:8080", name: "Local", host: "localhost:8080", status: .unreachable),
        ]
    }
}
