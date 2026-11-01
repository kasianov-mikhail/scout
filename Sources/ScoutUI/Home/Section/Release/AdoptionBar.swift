//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AdoptionBar: View {
    let versions: [ReleaseAdoption.Version]

    var body: some View {
        GeometryReader { proxy in
            let gaps = CGFloat(max(versions.count - 1, 0)) * 2
            let width = max(proxy.size.width - gaps, 0)

            HStack(spacing: 2) {
                ForEach(Array(versions.enumerated()), id: \.element.id) { index, version in
                    Rectangle()
                        .fill(version.stability.level.color.opacity(index == 0 ? 1 : 0.55))
                        .frame(width: width * CGFloat(version.share))
                        .overlay(alignment: .leading) {
                            if version.showsLabel {
                                Text(verbatim: version.id)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .padding(.leading, 4)
                            }
                        }
                }
            }
        }
        .frame(height: 24)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .accessibilityHidden(true)
    }
}

#Preview {
    AdoptionBar(versions: ReleaseAdoption.sample.versions)
        .padding()
}
