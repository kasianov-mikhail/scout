//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct WelcomePage: View {
    var body: some View {
        OnboardingPage(title: "Welcome to Scout", spacing: 32) {
            EmptyView()
        } content: {
            VStack(alignment: .leading, spacing: 20) {
                featureRow(
                    icon: "list.bullet",
                    title: "Events",
                    description: "Structured logging via swift-log"
                )
                featureRow(
                    icon: "chart.bar",
                    title: "Metrics",
                    description: "Counters and timers via swift-metrics"
                )
                featureRow(
                    icon: "checkmark.shield",
                    title: "Crashes",
                    description: "Automatic crash reports"
                )
            }
            .padding(.horizontal, 32)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .kerning(0.3)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WelcomePage()
}
