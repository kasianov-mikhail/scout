//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

private let referenceDash = StrokeStyle(lineWidth: 1.5, dash: [4, 4])

/// Draws the previous-period levels over the plot area using chart-proxy
/// coordinates, since bar marks cannot render dashed strokes.
///
struct ReferenceOverlay<T: ChartNumeric>: View {
    let pairs: [ComparisonPair<T>]
    let proxy: ChartProxy
    let plotFrame: CGRect
    let color: Color

    var body: some View {
        let levels = pairs.compactMap { ReferenceLevel(pair: $0, proxy: proxy, plotFrame: plotFrame) }
        let gains = levels.gains
        let drops = levels.drops

        ZStack {
            gains.slices
                .fill(.white.opacity(0.25))
            drops.slices
                .fill(color.opacity(0.12))
            gains.lines
                .stroke(style: referenceDash)
                .foregroundStyle(.white)
            drops.contours
                .stroke(style: referenceDash)
                .foregroundStyle(color)
        }
    }
}
