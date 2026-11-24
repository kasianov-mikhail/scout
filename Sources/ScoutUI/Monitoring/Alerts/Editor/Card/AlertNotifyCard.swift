//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AlertNotifyCard: View {
    @Binding var notifies: Bool

    var body: some View {
        AlertCard {
            Button {
                notifies.toggle()
            } label: {
                HStack(spacing: .space8) {
                    VStack(alignment: .leading, spacing: .space2) {
                        Text(verbatim: "This iPhone")
                            .font(.scoutRowStrong)
                            .foregroundStyle(notifies ? Color.fillAccent : Color.textPrimary)

                        Text(verbatim: notifies ? "Push notification" : "Off")
                            .font(.scoutMicro)
                            .foregroundStyle(notifies ? Color.fillAccent.opacity(0.75) : Color.fillLevel)
                    }

                    Spacer(minLength: 0)

                    if notifies {
                        Image(systemName: "checkmark")
                            .font(.scoutLabelCaps)
                            .foregroundStyle(Color.textLink)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: .rowSubtitle)
                .padding(.horizontal, .space8)
                .background(notifies ? Color.surfaceSelected : Color.clear)
                .contentShape(Rectangle())
            }
            .buttonStyle(.solid)
        }
    }
}
