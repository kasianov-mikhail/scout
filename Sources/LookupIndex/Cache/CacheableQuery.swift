//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

protocol CacheableQuery: SeriesQuery {
    var fingerprint: String { get }
}

extension EventSeriesQuery: CacheableQuery {
    var fingerprint: String {
        "\(name ?? "*")|*|*|\(bucket.rawValue)|*|event|sum"
    }
}

extension LifecycleSeriesQuery: CacheableQuery {
    var fingerprint: String {
        "\(name)|*|*|\(bucket.rawValue)|\(byVersion ? "version" : "*")|lifecycle|sum"
    }
}

extension MetricSeriesQuery: CacheableQuery {
    var fingerprint: String {
        "\(name ?? "*")|\(category ?? "*")|\(values?.rawValue ?? "*")|\(bucket.rawValue)|*|metric|\(reduce.rawValue)"
    }
}
