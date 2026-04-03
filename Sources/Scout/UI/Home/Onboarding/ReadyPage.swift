//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReadyPage: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Spacer()
            Spacer()

            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("You're all set")
                .font(.title)
                .bold()

            Text("Run your app and come back here to see your data.")
                .font(.body)
                .kerning(0.3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                dismiss()
            } label: {
                Text("Get Started")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    ReadyPage()
}
