//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct SettingsColumn: View {
    let title: String
    let value: String?
    var isLast = false

    var body: some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: title)
                .font(.scoutMicro)
                .foregroundStyle(Color.textMuted)
                .lineLimit(1)

            if let value {
                Text(verbatim: value)
                    .font(.scoutRowStrong)
                    .lineLimit(1)
            } else {
                SkeletonBar(width: 46, height: 11, delay: 0)
                    .frame(height: 18, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .space8)
        .padding(.vertical, .space8)
        .overlay(alignment: .trailing) {
            if !isLast {
                Separator(axis: .vertical)
            }
        }
    }
}
