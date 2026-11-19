//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct SendReadout: View {
    let summary: SendSummary

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: .space4) {
            if let pending = summary.pending {
                Text(verbatim: "\(pending)")
                    .font(.scoutNumberS)
            } else {
                SkeletonBar(width: 28, height: 16, delay: 0)
            }

            if summary.pending == nil {
                SkeletonBar(width: 74, height: 7, delay: 0)
                    .frame(height: 16, alignment: .leading)
            } else {
                Text(verbatim: "records waiting")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }

            if let lastSent = summary.lastSent {
                Text(verbatim: "· sent \(lastSent)")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            } else {
                if summary.pending == nil {
                    SkeletonBar(width: 4, height: 7, delay: 0)
                        .frame(height: 16, alignment: .leading)
                } else {
                    Text(verbatim: "·")
                        .font(.scoutCaption)
                        .foregroundStyle(Color.textMuted)
                }
                SkeletonBar(width: 74, height: 9, delay: 0)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, .space8)
        .padding(.vertical, .space10)
    }
}

struct SendSummary {
    var pending: Int? = nil
    var lastSent: String? = nil
}

extension SendSummary {
    static let sample = SendSummary(pending: 24, lastSent: "2 min ago")
    static let loading = SendSummary()
}
