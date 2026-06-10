//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

/// Bar-aligned geometry of one bucket's reference level, in overlay
/// coordinates.
///
struct ReferenceLevel {
    let x: ClosedRange<CGFloat>
    let count: CGFloat
    let reference: CGFloat
    let isClamped: Bool

    /// Whether the previous level lies above the bar (the value dropped).
    var isDrop: Bool { reference < count }
}

// MARK: - Projection

extension ReferenceLevel {
    /// Geometry for one bucket; nil for buckets without comparison data,
    /// empty in both periods, or falling outside the plot.
    ///
    init?<T: ChartNumeric>(pair: ComparisonPair<T>, proxy: ChartProxy, plotFrame: CGRect) {
        guard let referenceCount = pair.reference else {
            return nil
        }
        guard pair.count != .zero || referenceCount != .zero else {
            return nil
        }
        guard let barStartX = proxy.position(forX: pair.barStart), let barEndX = proxy.position(forX: pair.barEnd) else {
            return nil
        }
        guard let countY = proxy.position(forY: pair.count), let referenceY = proxy.position(forY: referenceCount) else {
            return nil
        }

        let reference = plotFrame.minY + referenceY

        self.init(
            x: (plotFrame.minX + barStartX)...(plotFrame.minX + barEndX),
            count: plotFrame.minY + countY,
            reference: max(reference, plotFrame.minY),
            isClamped: reference < plotFrame.minY
        )
    }
}

// MARK: - Paths

extension [ReferenceLevel] {
    /// Levels where the value grew or held its ground.
    var gains: Self { filter { !$0.isDrop } }

    /// Levels where the value dropped below the previous period.
    var drops: Self { filter(\.isDrop) }

    /// Rectangles between the two periods' levels.
    var slices: Path {
        Path { path in
            for level in self {
                let top = Swift.min(level.count, level.reference)
                let bottom = Swift.max(level.count, level.reference)
                path.addRect(
                    CGRect(
                        x: level.x.lowerBound,
                        y: top,
                        width: level.x.upperBound - level.x.lowerBound,
                        height: bottom - top
                    )
                )
            }
        }
    }

    /// Lines across the bars at the previous level, for buckets where the
    /// value grew.
    ///
    var lines: Path {
        Path { path in
            for level in self {
                path.move(to: CGPoint(x: level.x.lowerBound, y: level.reference))
                path.addLine(to: CGPoint(x: level.x.upperBound, y: level.reference))
            }
        }
    }

    /// Contours rising above the bars to the previous level, for buckets
    /// where the value dropped.
    ///
    /// A contour clipped by the plot's top edge is left without its cap to
    /// show that the previous level lies beyond the visible scale.
    ///
    var contours: Path {
        Path { path in
            for level in self {
                path.move(to: CGPoint(x: level.x.lowerBound, y: level.count))
                path.addLine(to: CGPoint(x: level.x.lowerBound, y: level.reference))
                if level.isClamped {
                    path.move(to: CGPoint(x: level.x.upperBound, y: level.reference))
                } else {
                    path.addLine(to: CGPoint(x: level.x.upperBound, y: level.reference))
                }
                path.addLine(to: CGPoint(x: level.x.upperBound, y: level.count))
            }
        }
    }
}
