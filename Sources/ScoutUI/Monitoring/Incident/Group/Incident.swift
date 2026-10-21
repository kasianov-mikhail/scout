//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

protocol Incident: Identifiable, Comparable, SessionContext where ID == String {
    static var kind: IncidentKind { get }

    var fingerprint: String { get }
    var name: String { get }
    var reason: String? { get }
    var stackTrace: [String] { get }
    var date: Date? { get }
}

extension Crash: Incident {
    static let kind = IncidentKind.crash
}

extension Hang: Incident {
    static let kind = IncidentKind.hang
}

extension ResourceException: Incident {
    static let kind = IncidentKind.resource
}
