//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

// MARK: - Record ↔ CKRecord

extension Record {
    /// Reads a `CKRecord` into the neutral representation, stashing the
    /// record's encoded system fields in ``metadata`` so a later write can
    /// preserve its change tag.
    ///
    init(ckRecord: CKRecord) {
        let fields = Dictionary(
            uniqueKeysWithValues: ckRecord.allKeys().compactMap { key in
                ckRecord[key].flatMap(RecordValue.init(any:)).map { (key, $0) }
            }
        )
        self.init(
            recordType: ckRecord.recordType,
            id: RecordID(recordName: ckRecord.recordID.recordName),
            fields: fields,
            metadata: ckRecord.encodedSystemFields
        )
    }

    /// Rebuilds a `CKRecord`, restoring system fields from ``metadata`` when
    /// present so a conflict retry targets the right record version.
    ///
    var ckRecord: CKRecord {
        let record = metadata.flatMap(CKRecord.decoded(systemFields:))
            ?? CKRecord(recordType: recordType, recordID: CKRecord.ID(recordName: id.recordName))
        for (key, value) in fields {
            record[key] = value.ckValue
        }
        return record
    }
}

extension RecordValue {
    /// The CloudKit-typed value to store under a record field.
    var ckValue: any CKRecordValueProtocol {
        switch self {
        case .string(let value): value
        case .int(let value): value
        case .double(let value): value
        case .date(let value): value
        case .bytes(let value): value
        case .strings(let value): value
        }
    }

    /// The value to substitute into an `NSPredicate` `%@` placeholder.
    fileprivate var predicateValue: CVarArg {
        switch self {
        case .string(let value): value
        case .int(let value): NSNumber(value: value)
        case .double(let value): NSNumber(value: value)
        case .date(let value): value as NSDate
        case .bytes(let value): value as NSData
        case .strings(let value): value as NSArray
        }
    }
}

extension CKRecord {
    fileprivate var encodedSystemFields: Data {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        encodeSystemFields(with: archiver)
        archiver.finishEncoding()
        return archiver.encodedData
    }

    fileprivate static func decoded(systemFields data: Data) -> CKRecord? {
        guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else { return nil }
        unarchiver.requiresSecureCoding = true
        let record = CKRecord(coder: unarchiver)
        unarchiver.finishDecoding()
        return record
    }
}

// MARK: - RecordQuery → CKQuery

extension CKQuery {
    convenience init(_ query: RecordQuery) {
        let predicate: NSPredicate =
            query.filters.isEmpty
            ? NSPredicate(value: true)
            : NSCompoundPredicate(type: .and, subpredicates: query.filters.map(\.predicate))

        self.init(recordType: query.recordType, predicate: predicate)

        if query.sort.count > 0 {
            sortDescriptors = query.sort.map { NSSortDescriptor(key: $0.field, ascending: $0.ascending) }
        }
    }
}

extension RecordFilter {
    fileprivate var predicate: NSPredicate {
        let value = value.predicateValue
        return switch op {
        case .equals: NSPredicate(format: "%K == %@", field, value)
        case .notEquals: NSPredicate(format: "%K != %@", field, value)
        case .greaterThan: NSPredicate(format: "%K > %@", field, value)
        case .greaterThanOrEquals: NSPredicate(format: "%K >= %@", field, value)
        case .lessThan: NSPredicate(format: "%K < %@", field, value)
        case .lessThanOrEquals: NSPredicate(format: "%K <= %@", field, value)
        case .in: NSPredicate(format: "%K IN %@", field, value)
        case .beginsWith: NSPredicate(format: "%K BEGINSWITH %@", field, value)
        }
    }
}

// MARK: - Cursor

extension CKQueryOperation.Cursor: RecordCursorToken {}
