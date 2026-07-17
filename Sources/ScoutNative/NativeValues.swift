//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore
import ScoutDB

extension ScoutCore.RecordValue {
    var storeValue: ScoutDB.RecordValue {
        switch self {
        case .string(let value):
            .string(value)
        case .int(let value):
            .int(value)
        case .double(let value):
            .double(value)
        case .date(let value):
            .date(value)
        case .bytes(let value):
            .bytes(value)
        case .strings(let value):
            .strings(value)
        }
    }

    init?(storeValue: ScoutDB.RecordValue) {
        switch storeValue {
        case .string(let value):
            self = .string(value)
        case .int(let value):
            self = .int(value)
        case .double(let value):
            self = .double(value)
        case .date(let value):
            self = .date(value)
        case .bytes(let value):
            self = .bytes(value)
        case .strings(let value):
            self = .strings(value)
        default:
            return nil
        }
    }
}

extension Record {
    init(entityRecord: EntityRecord) {
        self.init(recordType: entityRecord.entity, recordID: entityRecord.uuid)
        fields = entityRecord.values.compactMapValues(RecordValue.init(storeValue:))
        fields["uuid"] = .string(entityRecord.uuid)
    }

    // The `uuid` field lives in the Item envelope, not in a slot, so it is
    // stripped before encoding and re-injected from the envelope on decode.
    var storeValues: [String: ScoutDB.RecordValue] {
        var values = fields
        values["uuid"] = nil
        return values.mapValues(\.storeValue)
    }
}

extension RecordQuery.Filter {
    var storeFilter: EntityStore.Filter {
        EntityStore.Filter(field: field, op: storeMatch, value: value.storeValue)
    }

    private var storeMatch: EntityStore.Match {
        switch op {
        case .equals:
            .equals
        case .notEquals:
            .notEquals
        case .greaterThan:
            .greaterThan
        case .greaterThanOrEquals:
            .greaterThanOrEquals
        case .lessThan:
            .lessThan
        case .lessThanOrEquals:
            .lessThanOrEquals
        case .in:
            .in
        case .beginsWith:
            .beginsWith
        }
    }
}
