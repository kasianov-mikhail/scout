//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension [Backend] {
    func active(id: String) -> Backend? {
        first { $0.id == id } ?? first
    }

    var active: Backend? {
        active(id: UserDefaults.standard.string(forKey: "scout_active_backend") ?? "")
    }
}
