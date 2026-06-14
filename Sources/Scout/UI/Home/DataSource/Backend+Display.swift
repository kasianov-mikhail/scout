//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Backend {
    /// The name shown for this backend in the data-source picker.
    var displayName: String {
        switch self {
        case .cloudKit: "iCloud"
        case .server(let url, _): url.host ?? url.absoluteString
        }
    }

    /// The host line shown beneath the name in the data-source picker.
    var displayHost: String {
        switch self {
        case .cloudKit(let container): container.containerIdentifier ?? "CloudKit"
        case .server(let url, _): url.absoluteString
        }
    }
}
