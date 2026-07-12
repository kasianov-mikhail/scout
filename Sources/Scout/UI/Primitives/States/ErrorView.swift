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

    @State private var isRetrying: Bool

    init(description: Text, retry: (() -> Void)?, isRetrying: Bool = false) {
        self.description = description
        self.retry = retry
        _isRetrying = State(initialValue: isRetrying)
    }

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
                retryControl(retry).padding(8)
            }

            Spacer()
        }
        .lineSpacing(4)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func retryControl(_ retry: @escaping () -> Void) -> some View {
        if isRetrying {
            RingIndicator(size: 22)
                .frame(maxWidth: .infinity)
                .padding(10)
        } else {
            Button {
                isRetrying = true
                retry()
            } label: {
                Text(verbatim: "Retry")
            }
            .buttonStyle(.pill)
        }
    }
}

extension ErrorView {
    init(description: String, retry: (() -> Void)?, isRetrying: Bool = false) {
        self.init(description: Text(verbatim: description), retry: retry, isRetrying: isRetrying)
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

#Preview("Retrying") {
    ErrorView(
        description: "This is a sample error message that is intentionally made very long "
            + "to test how the ErrorView handles multiline text display. "
            + "It should properly wrap and be readable without any issues.",
        retry: {},
        isRetrying: true
    )
}
