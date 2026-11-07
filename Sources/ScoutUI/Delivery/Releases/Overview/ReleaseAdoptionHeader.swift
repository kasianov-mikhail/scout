//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ReleaseAdoptionHeader: View {
    let adoption: ReleaseAdoption

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(verbatim: adoption.headline)
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text(verbatim: "of sessions")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.systemGray))
            }

            AdoptionBar(
                versions: adoption.versions,
                height: 32,
                labelFont: .system(size: 11, weight: .bold, design: .monospaced),
                labelInset: 6
            )
            .padding(.top, 12)

            ReleaseLegend()
                .padding(.top, 8)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Color.separator
                .frame(height: 0.5)
        }
        .padding(.horizontal, 16)
    }
}

struct ReleaseLegend: View {
    var showsColors = true

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Stability.Level.allCases, id: \.self) { level in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(showsColors ? level.color : Color(.systemGray5))
                        .frame(width: 8, height: 8)

                    Text(verbatim: level.title)
                }
            }
        }
        .font(.system(size: 12))
        .foregroundStyle(Color(.systemGray))
    }
}

#Preview {
    ReleaseAdoptionHeader(adoption: .sample)
}
