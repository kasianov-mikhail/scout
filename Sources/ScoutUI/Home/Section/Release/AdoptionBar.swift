//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AdoptionBar: View {
    let versions: [ReleaseAdoption.Version]
    let height: CGFloat
    let labelSize: CGFloat
    let labelWeight: Font.Weight
    let labelInset: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let gaps = CGFloat(max(versions.count - 1, 0)) * 2
            let width = max(proxy.size.width - gaps, 0)

            HStack(spacing: 2) {
                ForEach(Array(versions.enumerated()), id: \.element.id) { index, version in
                    Rectangle()
                        .fill(version.stability.level.color)
                        .frame(width: width * CGFloat(version.share))
                        .overlay(alignment: .leading) {
                            if version.showsLabel {
                                Text(verbatim: version.id)
                                    .font(.weighted(size: labelSize, weight: labelWeight, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .padding(.leading, labelInset)
                            }
                        }
                        .opacity(index == 0 ? 1 : 0.55)
                }
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .accessibilityHidden(true)
    }
}

#Preview {
    AdoptionBar(
        versions: ReleaseAdoption.sample.versions,
        height: 32,
        labelSize: 11,
        labelWeight: .bold,
        labelInset: 6
    )
    .padding()
}
