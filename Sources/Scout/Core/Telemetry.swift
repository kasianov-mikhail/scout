//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// Represents telemetry data for various metric types.
///
/// The `Telemetry` enum provides cases for different types of telemetry events,
/// such as counters, meters, recorders, and timers. Each case can hold an
/// associated value representing the metric's data.
///
public enum Telemetry {

    /// An integer counter.
    case counter(Int)

    /// A floating-point counter.
    case floatingCounter(Double)

    /// Meter operations for telemetry.
    public enum Meter {

        /// Sets the meter to a specific value.
        case set(Double)

        /// Increments the meter by a value.
        case increment(Double)

        /// Decrements the meter by a value.
        case decrement(Double)
    }

    /// A meter event with a specific operation.
    case meter(Meter)

    /// Records a floating-point value.
    case recorder(Double)

    /// Records a time interval in seconds.
    case timer(Double)
}

