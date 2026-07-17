//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

struct ReadyPage: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        OnboardingPage(title: "You're all set", spacing: 24) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundStyle(.green)
        } content: {
            Text(verbatim: "Run your app and come back here to see your data.")
                .font(.body)
                .kerning(0.3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                dismiss()
            } label: {
                Text(verbatim: "Get Started")
            }
            .buttonStyle(.pill)
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ReadyPage()
}
