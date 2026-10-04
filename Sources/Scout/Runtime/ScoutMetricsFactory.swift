//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Metrics

/// A `swift-metrics` factory that records every counter, timer, meter, and recorder and syncs
/// it to the given backends.
///
/// Bootstrap it on its own, or multiplex it with factories of your own — Scout claims no
/// exclusive hold on the metrics system:
///
/// ```swift
/// MetricsSystem.bootstrap(
///     MultiplexMetricsHandler(factories: [
///         ScoutMetricsFactory(runtime: scout),
///         StreamMetricsFactory(),
///     ])
/// )
/// ```
///
/// The factory shares the ``Runtime`` it is given, so build the runtime once and pass
/// the same one here and to ``ScoutLogHandler``.
///
public struct ScoutMetricsFactory: MetricsFactory {
    let runtime: Runtime

    /// Creates a factory that records into the given runtime.
    ///
    /// - Parameter runtime: The runtime to record into, shared with every other Scout
    ///   handler.
    ///
    public init(runtime: Runtime) {
        self.runtime = runtime
    }

    public func makeCounter(label: String, dimensions: [(String, String)]) -> CounterHandler {
        TelemetryHandler(label: label, dimensions: dimensions, runtime: runtime)
    }

    public func makeFloatingPointCounter(label: String, dimensions: [(String, String)]) -> FloatingPointCounterHandler {
        TelemetryHandler(label: label, dimensions: dimensions, runtime: runtime)
    }

    public func makeMeter(label: String, dimensions: [(String, String)]) -> MeterHandler {
        GaugeHandler(label: label, runtime: runtime)
    }

    public func makeRecorder(label: String, dimensions: [(String, String)], aggregate: Bool) -> RecorderHandler {
        guard aggregate else { return GaugeHandler(label: label, runtime: runtime) }
        return TelemetryHandler(label: label, dimensions: dimensions, runtime: runtime)
    }

    public func makeTimer(label: String, dimensions: [(String, String)]) -> TimerHandler {
        TelemetryHandler(label: label, dimensions: dimensions, runtime: runtime)
    }

    public func destroyCounter(_ handler: CounterHandler) {}

    public func destroyMeter(_ handler: MeterHandler) {}

    public func destroyRecorder(_ handler: RecorderHandler) {}

    public func destroyTimer(_ handler: TimerHandler) {}
}
