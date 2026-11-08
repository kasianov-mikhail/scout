//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

struct SendSummary {
    var pending: Int? = nil
    var lastSent: String? = nil
}

extension SendSummary {
    static let sample = SendSummary(pending: 24, lastSent: "2 min ago")
    static let loading = SendSummary()
}
