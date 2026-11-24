//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AlertWatchSummary: View {
    let watch: AlertDraft.Watch
    let change: () -> Void

    var body: some View {
        AlertCard {
            HStack(spacing: .space8) {
                VStack(alignment: .leading, spacing: .space2) {
                    Text(verbatim: watch.templateTitle)
                        .font(.scoutRowStrong)

                    Text(verbatim: watch.summary)
                        .font(.scoutMicro)
                        .foregroundStyle(Color.textMuted)
                }

                Spacer(minLength: 0)

                Button(action: change) {
                    Text(verbatim: "Change")
                        .font(.scoutRowStrong)
                        .foregroundStyle(Color.textLink)
                }
                .buttonStyle(.solid)
            }
            .frame(height: .rowSubtitle)
            .padding(.horizontal, .space8)
        }
    }
}
