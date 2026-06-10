//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

private let referenceDash = StrokeStyle(lineWidth: 1.5, dash: [4, 4])

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

/// Draws the previous-period levels over the plot area using chart-proxy
/// coordinates, since bar marks cannot render dashed strokes.
///
struct ReferenceOverlay<T: ChartNumeric>: View {
    let pairs: [ComparisonPair<T>]
    let proxy: ChartProxy
    let plotFrame: CGRect
    let color: Color

    var body: some View {
        let levels = pairs.compactMap(level(for:))
        let gains = levels.filter { !$0.isDrop }
        let drops = levels.filter(\.isDrop)

        ZStack {
            slices(for: gains)
                .fill(.white.opacity(0.25))
            slices(for: drops)
                .fill(color.opacity(0.12))
            lines(for: gains)
                .stroke(style: referenceDash)
                .foregroundStyle(.white)
            contours(for: drops)
                .stroke(style: referenceDash)
                .foregroundStyle(color)
        }
    }

    /// Rectangles between the two periods' levels.
    func slices(for levels: [ReferenceLevel]) -> Path {
        Path { path in
            for level in levels {
                let top = min(level.count, level.reference)
                let bottom = max(level.count, level.reference)
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

    /// White dashed lines across the bars where the value grew.
    func lines(for levels: [ReferenceLevel]) -> Path {
        Path { path in
            for level in levels {
                path.move(to: CGPoint(x: level.x.lowerBound, y: level.reference))
                path.addLine(to: CGPoint(x: level.x.upperBound, y: level.reference))
            }
        }
    }

    /// Dashed contours rising above the bars where the value dropped.
    ///
    /// A contour clipped by the plot's top edge is left without its cap to
    /// show that the previous level lies beyond the visible scale.
    ///
    func contours(for levels: [ReferenceLevel]) -> Path {
        Path { path in
            for level in levels {
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

    /// Geometry for one bucket; nil for buckets without comparison data,
    /// empty in both periods, or falling outside the plot.
    ///
    func level(for pair: ComparisonPair<T>) -> ReferenceLevel? {
        guard let referenceCount = pair.reference else { return nil }
        guard pair.count != .zero || referenceCount != .zero else { return nil }

        guard let slotStart = proxy.position(forX: pair.bin.lowerBound), let slotEnd = proxy.position(forX: pair.bin.upperBound) else {
            return nil
        }
        guard let countY = proxy.position(forY: pair.count), let referenceY = proxy.position(forY: referenceCount) else {
            return nil
        }
        let width = slotEnd - slotStart
        let reference = plotFrame.minY + referenceY

        return ReferenceLevel(
            x: (plotFrame.minX + slotStart + width * barSlot.lowerBound)...(plotFrame.minX + slotStart + width * barSlot.upperBound),
            count: plotFrame.minY + countY,
            reference: max(reference, plotFrame.minY),
            isClamped: reference < plotFrame.minY
        )
    }
}
