//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
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
                        let scout = Runtime(
                            backends: [backend]
                        )

                        LoggingSystem.bootstrap {
                            ScoutLogHandler(
                                label: $0,
                                runtime: scout
                            )
                        }
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
                    Text(verbatim: "\(number)")
                        .font(.stepBadge)
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(.blue))
                    Text(label)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                Text(code.swiftSyntax)
                    .fixedSize(horizontal: false, vertical: true)
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
