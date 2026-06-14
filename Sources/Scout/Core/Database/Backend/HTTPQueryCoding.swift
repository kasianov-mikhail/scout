//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A record query in the server's wire format, the counterpart of `CKQuery`.
struct HTTPQuery: Codable, Equatable, Sendable {
    var recordType: String?
    var filters: [HTTPFilter]?
    var sort: [HTTPSort]?
    var limit: Int?
    var fields: [String]?
    var cursor: String?
}

struct HTTPFilter: Codable, Equatable, Sendable {
    enum Operator: String, Codable, Sendable {
        case equals
        case notEquals
        case greaterThan
        case greaterThanOrEquals
        case lessThan
        case lessThanOrEquals
        case `in`
        case beginsWith
    }

    let field: String
    let op: Operator
    let value: HTTPFieldValue
}

struct HTTPSort: Codable, Equatable, Sendable {
    let field: String
    let ascending: Bool
}

// MARK: - CKQuery Translation

/// The query uses an `NSPredicate` shape Scout never produces, so the
/// server has no equivalent for it.
///
struct UnsupportedQueryError: LocalizedError {
    let format: String

    init(predicate: NSPredicate) {
        format = predicate.predicateFormat
    }

    var errorDescription: String? {
        "The predicate '\(format)' cannot be sent to a Scout server"
    }
}

extension HTTPQuery {
    /// Translates the `CKQuery` shapes Scout builds — compound ANDs over
    /// comparisons (`==`, `!=`, `<`, `<=`, `>`, `>=`, `IN`, `BEGINSWITH`)
    /// plus `TRUEPREDICATE` — into the server's filter language.
    ///
    init(query: CKQuery, fields: [CKRecord.FieldKey]?, limit: Int?) throws {
        self.recordType = query.recordType
        self.filters = try Self.filters(of: query.predicate)
        self.fields = fields

        if let limit, limit != CKQueryOperation.maximumResults {
            self.limit = limit
        }

        let sort = (query.sortDescriptors ?? []).compactMap { descriptor in
            descriptor.key.map { HTTPSort(field: $0, ascending: descriptor.ascending) }
        }
        if !sort.isEmpty {
            self.sort = sort
        }
    }

    private static func filters(of predicate: NSPredicate) throws -> [HTTPFilter] {
        if predicate.predicateFormat == "TRUEPREDICATE" {
            return []
        }

        if let compound = predicate as? NSCompoundPredicate {
            guard compound.compoundPredicateType == .and else {
                throw UnsupportedQueryError(predicate: predicate)
            }
            return try (compound.subpredicates as? [NSPredicate] ?? []).flatMap(filters)
        }

        if let comparison = predicate as? NSComparisonPredicate {
            return try [filter(of: comparison)]
        }

        throw UnsupportedQueryError(predicate: predicate)
    }

    private static func filter(of comparison: NSComparisonPredicate) throws -> HTTPFilter {
        guard comparison.leftExpression.expressionType == .keyPath, comparison.rightExpression.expressionType == .constantValue else {
            throw UnsupportedQueryError(predicate: comparison)
        }

        let field = comparison.leftExpression.keyPath

        let op: HTTPFilter.Operator =
            switch comparison.predicateOperatorType {
            case .equalTo: .equals
            case .notEqualTo: .notEquals
            case .greaterThan: .greaterThan
            case .greaterThanOrEqualTo: .greaterThanOrEquals
            case .lessThan: .lessThan
            case .lessThanOrEqualTo: .lessThanOrEquals
            case .in: .in
            case .beginsWith: .beginsWith
            default: throw UnsupportedQueryError(predicate: comparison)
            }

        guard let constant = comparison.rightExpression.constantValue, let value = Self.value(of: constant) else {
            throw UnsupportedQueryError(predicate: comparison)
        }

        return HTTPFilter(field: field, op: op, value: value)
    }

    private static func value(of constant: Any) -> HTTPFieldValue? {
        switch constant {
        case let values as [String]:
            .strings(values)
        case let value as UUID:
            .string(value.uuidString)
        default:
            HTTPFieldValue(recordValue: constant)
        }
    }
}

// MARK: - Envelopes

struct HTTPWriteRequest: Codable {
    let records: [HTTPRecord]
}

struct HTTPQueryResponse: Codable {
    let records: [HTTPRecord]
    let cursor: String?
}
