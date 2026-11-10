//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

enum BackendRetention: String, CaseIterable, Identifiable {
    case days30
    case days90
    case year
    case forever

    var id: Self { self }

    var title: String {
        switch self {
        case .days30:
            "30 days"
        case .days90:
            "90 days"
        case .year:
            "1 year"
        case .forever:
            "Forever"
        }
    }

    static func key(id: String) -> String {
        "scout_backend_retention_\(id)"
    }
}
