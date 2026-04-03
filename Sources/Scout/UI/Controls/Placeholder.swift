//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Placeholder: View {
    let text: String
    var systemImage: String?
    var description: String?

    var body: some View {
        VStack(spacing: 12) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 36))
                    .foregroundStyle(.gray.opacity(0.5))
            }

            Text(text)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.gray.opacity(0.7))

            if let description {
                Text(description)
                    .font(.body)
                    .kerning(0.3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview("Text Only") {
    Placeholder(text: "No results")
}

#Preview("With Icon") {
    Placeholder(
        text: "No crashes",
        systemImage: "checkmark.shield",
        description: "No crash reports have been recorded"
    )
}
