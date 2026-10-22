//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

package enum Telemetry {
    case counter(Int)
    case floatingCounter(Double)
    case meter(Double)
    case recorder(Double)
    case timer(Double)
}

package enum ResetMarker {
    package static let category = "counter_reset"
}
