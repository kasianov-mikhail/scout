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

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Stability.Level.allCases, id: \.self) { level in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(squareColor ?? level.color)
                        .frame(width: squareSize, height: squareSize)

                    Text(verbatim: level.title)
                }
            }
        }
        .font(.weight450(size: 12))
        .foregroundStyle(Color(.systemGray))
    }
}

#Preview {
    VStack(alignment: .leading) {
        AdoptionLegend(squareSize: 7, squareColor: nil)
        AdoptionLegend(squareSize: 8, squareColor: nil)
        AdoptionLegend(squareSize: 8, squareColor: Color(.systemGray5))
    }
    .padding()
}
