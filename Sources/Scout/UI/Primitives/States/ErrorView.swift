//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ErrorView: View {
    let description: Text
    let retry: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.yellow)

            Text(verbatim: "An error occurred")
                .font(.title2)
                .bold()

            description
                .font(.body)
                .multilineTextAlignment(.center)

            if let retry {
                Button(action: retry) {
                    Text(verbatim: "Retry")
                }
                .buttonStyle(.pill)
                .padding(8)
            }

            Spacer()
        }
        .lineSpacing(4)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension ErrorView {
    init(description: String, retry: (() -> Void)?) {
        self.description = Text(verbatim: description)
        self.retry = retry
    }
}

#Preview("ErrorView") {
    ErrorView(
        description: "This is a sample error message that is intentionally made very long "
            + "to test how the ErrorView handles multiline text display. "
            + "It should properly wrap and be readable without any issues.",
        retry: {}
    )
}
