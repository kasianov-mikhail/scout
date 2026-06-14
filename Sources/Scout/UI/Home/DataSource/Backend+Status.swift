//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Backend {
    /// A live reachability probe driving the data-source status dots.
    ///
    /// Unlike the sync pre-flight `checkAvailability` — a no-op for servers so
    /// a single down server never blocks syncing the others — this actually
    /// reaches the backend, so the dot reflects its real state: an unavailable
    /// iCloud account or an unreachable server both read as `.unreachable`.
    ///
    func probeStatus() async -> ServerStatus {
        switch self {
        case .cloudKit(let container):
            let status = try? await container.accountStatus()
            return status == .available ? .reachable : .unreachable
        case .server(let url, let apiKey):
            do {
                try await HTTPDatabase(url: url, apiKey: apiKey).ping()
                return .reachable
            } catch {
                return .unreachable
            }
        }
    }
}
