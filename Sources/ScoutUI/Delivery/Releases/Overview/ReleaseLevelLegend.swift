//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleaseLevelLegend: View {
    let squareSize: CGFloat
    var fill: Color?

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Stability.Level.allCases, id: \.self) { level in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(fill ?? level.color)
                        .frame(width: squareSize, height: squareSize)

                    Text(verbatim: level.title.lowercased())
                }
            }
        }
        .font(.caption)
        .foregroundStyle(Color(.systemGray))
    }
}

#Preview {
    VStack {
        ReleaseLevelLegend(squareSize: 8)
        ReleaseLevelLegend(squareSize: 7, fill: Color(.systemGray5))
    }
}
