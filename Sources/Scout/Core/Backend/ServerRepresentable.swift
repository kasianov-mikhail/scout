//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Can be serialized into a record for upload to a Scout server.
///
/// Most types reuse their record as-is. Metrics are the exception: on
/// CloudKit they exist only as client-maintained matrices, but Scout servers
/// aggregate natively and take the raw values instead, as
/// `IntMetric`/`DoubleMetric` records.
///
/// `UserActivityObject` is deliberately absent: servers derive DAU/WAU/MAU
/// from `Session` records, so activity flags never leave the device.
///
protocol ServerRepresentable {
    var toServerRecord: Record { get }
}

extension ServerRepresentable where Self: RecordRepresentable {
    var toServerRecord: Record { toRecord }
}

extension EventObject: ServerRepresentable {}
extension SessionObject: ServerRepresentable {}
extension LaunchObject: ServerRepresentable {}
extension InstallObject: ServerRepresentable {}
extension DeviceObject: ServerRepresentable {}
extension VersionObject: ServerRepresentable {}
extension CrashObject: ServerRepresentable {}

// MARK: - Metrics

extension MetricsObject {
    /// Builds the raw metric record.
    ///
    /// The matrix pipeline stores the telemetry type in the matrix
    /// `category` field, and the server keeps that name so aggregated
    /// metrics come back shaped identically.
    ///
    /// Metrics carry no UUID attribute, so the stable Core Data object URI
    /// names the record — re-uploading the same object after a partial
    /// sync upserts instead of double-counting.
    ///
    fileprivate func serverRecord<V: RecordValueConvertible>(type: String, value: V) -> Record {
        var record = Record(
            recordType: type,
            id: RecordID(recordName: objectID.uriRepresentation().absoluteString)
        )

        record["name"] = name
        record["category"] = telemetry
        record["value"] = value
        record["date"] = date
        record["session_id"] = sessionID.uuidString

        record.setValues(metadata)

        return record
    }
}

extension IntMetricsObject: ServerRepresentable {
    static let serverRecordType = "IntMetric"

    var toServerRecord: Record {
        serverRecord(type: Self.serverRecordType, value: value)
    }
}

extension DoubleMetricsObject: ServerRepresentable {
    static let serverRecordType = "DoubleMetric"

    var toServerRecord: Record {
        serverRecord(type: Self.serverRecordType, value: value)
    }
}
