//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ErrorView: View {
    let error: Error

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.yellow)

            Text("An error occurred")
                .font(.title2)
                .bold()

            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview("ErrorView") {
    ErrorView(
        error: NSError(
            domain: "",
            code: 0,
            userInfo: [
                NSLocalizedDescriptionKey: "This is a sample error message to demonstrate the \(ErrorView.self)."
            ]
        )
    )
}
