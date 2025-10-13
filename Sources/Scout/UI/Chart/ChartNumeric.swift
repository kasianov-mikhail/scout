//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Foundation

/// A UI-layer specialization of `MatrixValue` for chart rendering.
///
/// ChartNumeric represents values that:
///
/// - Retain the domain/storage semantics of `MatrixValue`
/// - Additionally conform to `Plottable`, making the values suitable for
///   use with the Charts framework (e.g., axis-compatible, display-ready).
///
/// Use `ChartNumeric` in UI components such as `ChartPoint` and
/// matrix-to-chart transformations to guarantee that values are both
/// persistable (domain layer) and plottable (UI layer).
///
typealias ChartNumeric = MatrixValue & Plottable
