//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RetentionValueLabel: View {
    let kept: String?
    let rate: String?
    let pending: String?

    var body: some View {
        if let kept, let rate {
            HStack(spacing: 0) {
                Text(verbatim: kept)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.trendPositive)

                Text(verbatim: " · \(rate)")
                    .foregroundStyle(Color(.systemGray))
            }
            .font(.weight450(size: 13, design: .monospaced))
        } else {
            Text(verbatim: pending ?? "—")
                .font(.weight450(size: 13, design: .monospaced))
                .foregroundStyle(Color.pending)
        }
    }
}

#Preview {
    VStack(alignment: .trailing) {
        RetentionValueLabel(kept: "192", rate: "20%", pending: nil)
        RetentionValueLabel(kept: nil, rate: nil, pending: "in 2 d")
    }
}
