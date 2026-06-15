//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A destination Scout syncs analytics to and reads them back from.
///
/// Scout can run against an Apple-native CloudKit container (``NativeBackend``),
/// against one or more self-hosted Scout servers (``HostedBackend``), or against
/// any mix of them at once:
/// every raw record is uploaded to every backend, while reads go to the first
/// backend in the list (the primary).
///
/// The protocol is an empty marker: the host constructs concrete backends and
/// passes them as `[any Backend]`, keeping each backend's transport — and, for
/// CloudKit, its `CKContainer` — out of the neutral layer.
///
public protocol Backend: Sendable {}

/// A backend that can resolve itself into the capabilities Scout's pipeline
/// and UI need.
///
/// Concrete backends conform; the marker ``Backend`` stays empty so the public
/// surface exposes nothing CloudKit- or HTTP-specific.
///
protocol BackendResolving: Backend {
    var resolved: ResolvedBackend { get }
}

/// The full database surface a backend must provide.
protocol BackendDatabase: RecordWriter, RecordReader, RecordLookup, Sendable {}

/// A backend resolved into its database plus the traits the sync pipeline and
/// the data-source UI branch on.
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

    /// The name shown for this backend in the data-source picker.
    var displayName: String = ""

    /// The host line shown beneath the name in the data-source picker.
    var displayHost: String = ""

    /// A live reachability probe driving the data-source status dots.
    var probeStatus: @Sendable () async -> BackendStatus = { .unknown }

    /// Whether the backend should surface an account/sign-in warning.
    var accountWarning: @Sendable () async -> Bool = { false }

    /// Verifies the backend's schema, throwing a `SchemaError` if outdated.
    var verifySchema: @Sendable () async throws -> Void = {}

    /// A side effect to run once during `setup`, e.g. a parallelism check or a
    /// cleartext-key warning.
    ///
    /// Runs on the main actor, like `setup` itself.
    ///
    var onSetup: @MainActor @Sendable () -> Void = {}
}

extension [Backend] {
    /// The backends resolved into their capabilities, dropping any that cannot
    /// resolve (an unknown custom conformer of the empty ``Backend`` marker).
    ///
    var resolved: [ResolvedBackend] {
        compactMap { ($0 as? BackendResolving)?.resolved }
    }

    /// The database UI reads go to — the first backend's.
    var primaryDatabase: (any BackendDatabase)? {
        resolved.first?.database
    }
}
