//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

protocol SessionContext {
    var sessionID: UUID? { get }
    var deviceID: UUID? { get }
}

protocol Incident: Identifiable, Comparable, SessionContext where ID == String {
    static var kind: IncidentKind { get }

    var fingerprint: String { get }
    var name: String { get }
    var reason: String? { get }
    var stackTrace: [String] { get }
    var date: Date? { get }
    var summaryDetail: String? { get }
}

extension Incident {
    var summaryDetail: String? {
        nil
    }
}

extension Crash: Incident {
    static let kind = IncidentKind.crash
}

extension Hang: Incident {
    static let kind = IncidentKind.hang

    var summaryDetail: String? {
        duration.duration
    }
}

extension ResourceException: Incident {
    static let kind = IncidentKind.resource

    var summaryDetail: String? {
        guard let amount = ResourceAmount(reason: reason) else {
            return nil
        }
        switch resourceKind {
        case .cpu:
            return "\(amount.text) CPU"
        case .diskWrite:
            return "\(amount.text) disk"
        case nil:
            return amount.text
        }
    }
}
