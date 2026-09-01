//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum CacheKey {
    case lookup(scope: String, recordName: String, fields: [String]?)
    case series(scope: String, query: SeriesQuery)

    var fingerprint: String {
        components.joined(separator: "|")
    }

    private var components: [String] {
        switch self {
        case .lookup(let scope, let recordName, let fields):
            [
                scope,
                "lookup",
                recordName,
                fields.map { $0.sorted().joined(separator: ",") } ?? "*",
            ]
        case .series(let scope, let query):
            [
                scope, "series",
                query.name ?? "*",
                query.category ?? "*",
                query.values?.rawValue ?? "*",
                query.bucket.rawValue,
                query.byVersion ? "version" : "*",
                query.source?.rawValue ?? "*",
                query.reduce.rawValue,
            ]
        }
    }
}
