//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// This type is not used directly in the current version of the package,
/// but is reserved for future telemetry expansion and metrics export.
/// Keeping it now helps establish a consistent data format (see Telemetry.Export)
/// and simplifies integration in upcoming releases.
///
enum Telemetry {
    case counter(Int)
    case floatingCounter(Double)

    enum Meter {
        case set(Double)
        case increment(Double)
        case decrement(Double)
    }

    case meter(Meter)
    case recorder(Double)
    case timer(Double)
}
