//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

struct ReferenceLevel {
    let x: ClosedRange<CGFloat>
    let value: CGFloat
    let reference: CGFloat
    let isClamped: Bool

    var isDrop: Bool { reference < value }
}

extension ReferenceLevel {
    init?<T: ChartNumeric>(pair: ComparisonPair<T>, proxy: ChartProxy, plotFrame: CGRect) {
        guard let referenceValue = pair.reference else {
            return nil
        }
        guard pair.value != .zero || referenceValue != .zero else {
            return nil
        }
        guard let barStartX = proxy.position(forX: pair.barStart), let barEndX = proxy.position(forX: pair.barEnd) else {
            return nil
        }
        guard let valueY = proxy.position(forY: pair.value), let referenceY = proxy.position(forY: referenceValue) else {
            return nil
        }

        let reference = plotFrame.minY + referenceY

        self.init(
            x: (plotFrame.minX + barStartX)...(plotFrame.minX + barEndX),
            value: plotFrame.minY + valueY,
            reference: max(reference, plotFrame.minY),
            isClamped: reference < plotFrame.minY
        )
    }
}

extension [ReferenceLevel] {
    var gains: Self { filter { !$0.isDrop } }

    var drops: Self { filter(\.isDrop) }

    var slices: Path {
        Path { path in
            for level in self {
                let top = Swift.min(level.value, level.reference)
                let bottom = Swift.max(level.value, level.reference)
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

    var lines: Path {
        Path { path in
            for level in self {
                path.move(to: CGPoint(x: level.x.lowerBound, y: level.reference))
                path.addLine(to: CGPoint(x: level.x.upperBound, y: level.reference))
            }
        }
    }

    var contours: Path {
        Path { path in
            for level in self {
                path.move(to: CGPoint(x: level.x.lowerBound, y: level.value))
                path.addLine(to: CGPoint(x: level.x.lowerBound, y: level.reference))
                if level.isClamped {
                    path.move(to: CGPoint(x: level.x.upperBound, y: level.reference))
                } else {
                    path.addLine(to: CGPoint(x: level.x.upperBound, y: level.reference))
                }
                path.addLine(to: CGPoint(x: level.x.upperBound, y: level.value))
            }
        }
    }
}
