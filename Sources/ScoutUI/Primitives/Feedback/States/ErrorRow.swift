//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ErrorRow: View {
    let description: String
    let retry: () async -> Void

    @State private var isRetrying = false

    var body: some View {
        HStack(spacing: .space12) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(Color.textCaution)

            Text(verbatim: description)
                .font(.scoutRow)
                .lineLimit(1)

            Spacer()

            retryControl
        }
        .frame(height: .rowRegular)
    }

    private var retryControl: some View {
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
            .buttonStyle(.borderless)
            .opacity(isRetrying ? 0 : 1)
            .disabled(isRetrying)

            if isRetrying {
                RingIndicator(size: 18)
            }
        }
    }
}

#Preview {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            ErrorRow(description: "The request timed out.") {}
            ErrorRow(description: "A much longer error description that explains what exactly went wrong while loading.") {}
        }
        .padding(.horizontal, .gutter)
    }
    .scrollIndicators(.hidden)
}
