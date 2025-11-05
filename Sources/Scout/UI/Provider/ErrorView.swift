//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ErrorView: View {
    let error: Error
    let retry: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.yellow)

            Text("An error occurred")
                .font(.title2)
                .bold()

            Text(error.localizedDescription)
                .font(.body)
                .multilineTextAlignment(.center)

            if let retry {
                Button(action: retry) {
                    Text("Retry")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
                }
                .padding(8)
            }

            Spacer()
        }
        .lineSpacing(4)
        .padding()
    }
}

#Preview("ErrorView") {
    let errorText =
        "This is a sample error message that is intentionally made very long to test how the \(ErrorView.self) handles multiline text display. It should properly wrap and be readable without any issues."

    ErrorView(
        error: NSError(
            domain: "",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: errorText]
        ),
        retry: {}
    )
}
