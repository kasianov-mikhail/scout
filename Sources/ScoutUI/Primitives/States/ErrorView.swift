//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

struct ErrorView: View {
    let description: Text
    let retry: (() async -> Void)?

    @State private var isRetrying: Bool

    init(description: Text, retry: (() async -> Void)?, isRetrying: Bool = false) {
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

    private func retryControl(_ retry: @escaping () async -> Void) -> some View {
        ZStack {
            Button {
                isRetrying = true
                Task {
                    await retry()
                    isRetrying = false
                }
            } label: {
                Text(verbatim: "Retry")
            }
            .buttonStyle(.pill)
            .opacity(isRetrying ? 0 : 1)
            .disabled(isRetrying)

            if isRetrying {
                RingIndicator(size: 22)
            }
        }
    }
}

extension ErrorView {
    init(description: String, retry: (() async -> Void)?, isRetrying: Bool = false) {
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
