//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

public enum Telemetry {
    case counter(Int)
    case floatingCounter(Double)

    public enum Meter {
        case set(Double)
        case increment(Double)
        case decrement(Double)
    }

    case meter(Meter)
    case recorder(Double)
    case timer(Double)
}
