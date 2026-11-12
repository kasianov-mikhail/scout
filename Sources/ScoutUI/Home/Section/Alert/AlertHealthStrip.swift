//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AlertHealthStrip: View {
    let buckets: [AlertHistory.Bucket]

    var body: some View {
        HStack(spacing: .space2) {
            ForEach(buckets.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: .radiusBar)
                    .fill(buckets[index].color)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 10)
        .accessibilityHidden(true)
    }
}

extension AlertHistory.Bucket {
    fileprivate var color: Color {
        switch self {
        case .clear: Color.surfaceSkeleton
        case .muted: Color.fillLevel
        case .firing: .fillDanger
        }
    }
}

#Preview {
    AlertHealthStrip(buckets: AlertHistory.sample.buckets)
        .padding()
}
