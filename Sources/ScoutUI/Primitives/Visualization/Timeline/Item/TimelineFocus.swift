//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct TimelineFocus {
    let id: String
    let date: Date?
    let installID: UUID?
    let kind: IncidentKind?
}

extension TimelineFocus {
    init(event: Event) {
        self.init(id: event.id, date: event.date, installID: event.installID, kind: nil)
    }

    init(crash: Crash) {
        self.init(id: crash.id, date: crash.date, installID: nil, kind: IncidentKind.crash)
    }

    init(hang: Hang) {
        self.init(id: hang.id, date: hang.date, installID: nil, kind: IncidentKind.hang)
    }

    init(resource: ResourceException) {
        self.init(id: resource.id, date: resource.date, installID: nil, kind: IncidentKind.resource)
    }
}

extension TimelineFocus {
    var chip: String? {
        switch kind {
        case .crash?:
            "This crash"
        case .hang?:
            "This hang"
        case .resource?:
            "This resource"
        case nil:
            nil
        }
    }
}
