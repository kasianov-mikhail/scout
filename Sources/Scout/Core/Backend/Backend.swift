//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

public struct Backend: Sendable {
    let id: String
    let database: any Database
    let checkAvailability: @Sendable () async -> Bool
    let displayName: String
    let displayHost: String

    var aggregator: (any ClientAggregating)? = nil
    var probeStatus: @Sendable () async -> Status = { .unknown }
    var accountWarning: @Sendable () async -> Bool = { false }
    var verifySchema: @Sendable () async throws -> Void = {}
    var onSetup: @MainActor @Sendable () -> Void = {}
}
