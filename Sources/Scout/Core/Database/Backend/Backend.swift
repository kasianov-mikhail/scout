//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A destination Scout syncs analytics to and reads them back from.
///
/// Scout can run against CloudKit, against one or more Scout servers, or
/// against any mix of them at once: every raw record is uploaded to every
/// backend, while reads go to the first backend in the list (the primary).
///
public enum Backend: Sendable {
    /// The CloudKit container Scout traditionally syncs to. CloudKit cannot
    /// aggregate server-side, so the client also maintains matrix records.
    case cloudKit(CKContainer)

    /// A Scout server (`scout-server`). Aggregation happens in SQL on the
    /// server, so only raw records are uploaded — including raw metric
    /// values, which on CloudKit exist solely as matrices.
    case server(url: URL, apiKey: String? = nil)
}

/// The full database surface a backend must provide.
protocol BackendDatabase: RecordWriter, RecordReader, RecordLookup, Sendable {}

extension CKDatabase: BackendDatabase {}
extension HTTPDatabase: BackendDatabase {}

/// A backend resolved into its database plus the traits the sync pipeline
/// branches on.
///
struct ResolvedBackend: Sendable {
    /// Stable identity used to track per-record delivery across sync cycles.
    ///
    /// Derived from the destination itself — the CloudKit container
    /// identifier or the server URL — so it survives reordering or
    /// re-resolving the backend list.
    ///
    let id: String

    let database: any BackendDatabase

    /// Whether the client must maintain matrix records on this backend.
    ///
    /// True for CloudKit; Scout servers aggregate natively.
    ///
    let needsClientAggregation: Bool

    /// Whether raw metric values can be uploaded.
    ///
    /// Scout servers accept them; on CloudKit metrics exist only as matrices.
    ///
    let acceptsRawMetrics: Bool

    /// Throws when the backend cannot accept uploads right now.
    let checkAvailability: @Sendable () async throws -> Void
}

extension Backend {
    var resolved: ResolvedBackend {
        switch self {
        case .cloudKit(let container):
            ResolvedBackend(
                id: container.containerIdentifier ?? "cloudKit",
                database: container.publicCloudDatabase,
                needsClientAggregation: true,
                acceptsRawMetrics: false,
                checkAvailability: {
                    guard try await container.accountStatus() == .available else {
                        throw SyncController.NotLoggedInError()
                    }
                }
            )
        case .server(let url, let apiKey):
            ResolvedBackend(
                id: url.absoluteString,
                database: HTTPDatabase(url: url, apiKey: apiKey),
                needsClientAggregation: false,
                acceptsRawMetrics: true,
                checkAvailability: {}
            )
        }
    }
}

extension [Backend] {
    /// The database UI reads go to — the first backend's.
    var primaryDatabase: (any BackendDatabase)? {
        first?.resolved.database
    }
}
