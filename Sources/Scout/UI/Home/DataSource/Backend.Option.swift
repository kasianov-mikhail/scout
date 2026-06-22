//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension Backend {
    struct Option: Identifiable {
        let id: String
        var name: String
        var host: String
        var status: Status
    }
}

extension Backend.Status {
    var color: Color {
        switch self {
        case .reachable: .green
        case .unreachable: .red
        case .unknown: .gray
        }
    }
}

extension Backend {
    static var sample: Option {
        Option(id: "https://api.scout.app", name: "Production", host: "api.scout.app", status: .reachable)
    }

    static var samples: [Option] {
        [
            Option(id: "https://api.scout.app", name: "Production", host: "api.scout.app", status: .reachable),
            Option(id: "https://staging.scout.app", name: "Staging", host: "staging.scout.app", status: .unknown),
            Option(id: "http://localhost:8080", name: "Local", host: "localhost:8080", status: .unreachable),
        ]
    }
}
