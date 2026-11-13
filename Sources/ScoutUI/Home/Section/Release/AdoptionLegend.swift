//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AdoptionLegend: View {
    let squareSize: CGFloat
    let squareColor: Color?
    var dashed = false

    var body: some View {
        HStack(spacing: .space12) {
            ForEach(Stability.Level.allCases, id: \.self) { level in
                HStack(spacing: .space4) {
                    square(level: level)

                    Text(verbatim: level.title)
                }
            }
        }
        .font(.scoutFootnote)
        .foregroundStyle(Color.textMuted)
    }

    @ViewBuilder private func square(level: Stability.Level) -> some View {
        if dashed {
            RoundedRectangle(cornerRadius: .radiusBar)
                .strokeBorder(squareColor ?? Color.surfaceBarIdle, style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                .frame(width: squareSize, height: squareSize)
        } else {
            RoundedRectangle(cornerRadius: .radiusBar)
                .fill(squareColor ?? level.color)
                .frame(width: squareSize, height: squareSize)
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        AdoptionLegend(squareSize: 7, squareColor: nil)
        AdoptionLegend(squareSize: 8, squareColor: nil)
        AdoptionLegend(squareSize: 8, squareColor: Color.surfaceSkeleton)
        AdoptionLegend(squareSize: 7, squareColor: Color.surfaceBarIdle, dashed: true)
    }
    .padding()
}
