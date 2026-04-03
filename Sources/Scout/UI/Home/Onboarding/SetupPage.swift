//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SetupPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Spacer()
            Spacer()

            Text("Quick Setup")
                .font(.title)
                .bold()

            VStack(spacing: 12) {
                codeStep("try await setup(container: .default())")
                codeStep("logger.info(\"hello\")")
                codeStep("Counter(label: \"taps\").increment()")
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
        }
    }

    private func codeStep(_ code: String) -> some View {
        Text(code)
            .font(.system(size: 13, design: .monospaced))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

#Preview {
    SetupPage()
}
