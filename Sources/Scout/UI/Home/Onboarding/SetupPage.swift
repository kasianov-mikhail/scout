//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SetupPage: View {
    var body: some View {
        OnboardingPage(title: "Quick Setup", spacing: 32) {
            EmptyView()
        } content: {
            VStack(alignment: .leading, spacing: 20) {
                Step(
                    number: 1,
                    label: "Initialize Scout in your app",
                    code: """
                        try await setup(
                            backends: [.cloudKit(container: .default())]
                        )
                        """
                )
                Step(
                    number: 2,
                    label: "Log a structured event",
                    code: "logger.info(\"hello\")"
                )
                Step(
                    number: 3,
                    label: "Track a metric",
                    code: "Counter(label: \"taps\").increment()"
                )
            }
            .padding(.horizontal, 24)
        }
    }

    private struct Step: View {
        let number: Int
        let label: String
        let code: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text("\(number)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(.blue))
                    Text(label)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                Text(code.swiftSyntax)
                    .lineLimit(code.reduce(into: 1) { count, character in
                        if character == "\n" { count += 1 }
                    })
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .codeChipStyle()
                    .padding(.leading, 32)
            }
        }
    }
}

#Preview {
    SetupPage()
}
