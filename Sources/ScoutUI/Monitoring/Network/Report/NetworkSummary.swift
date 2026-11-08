//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct NetworkSummary {
    let requests: Int
    let successRate: Stability?
    let p99: TimeInterval?
    let endpoints: Int
}

extension NetworkSummary {
    var text: String {
        let requestNoun = requests == 1 ? "request" : "requests"
        let endpointNoun = endpoints == 1 ? "endpoint" : "endpoints"
        return "\(requests.networkCount) \(requestNoun) across \(endpoints) \(endpointNoun)"
    }
}
