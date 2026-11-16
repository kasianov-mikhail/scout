//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct AccountUnavailableView: View {
    let issue: Backend.AccountError
    let endpoint: String
    let retry: () async -> Void

    @Environment(\.openURL) private var openURL
    @State private var isRetrying = false

    var body: some View {
        ErrorCodeScreen(cloud: true, title: issue.title, message: issue.localizedDescription, endpoint: endpoint) {
            HStack(spacing: .space10) {
                Button {
                    openURL(settingsURL)
                } label: {
                    Text(verbatim: "Open Settings")
                }
                .buttonStyle(ErrorActionButtonStyle(role: .secondaryAccent))

                Button {
                    isRetrying = true
                    Task {
                        await retry()
                        isRetrying = false
                    }
                } label: {
                    ZStack {
                        Text(verbatim: "Try Again")
                            .opacity(isRetrying ? 0 : 1)

                        if isRetrying {
                            RingIndicator(size: 20)
                        }
                    }
                }
                .buttonStyle(ErrorActionButtonStyle(role: .primary))
                .disabled(isRetrying)
            }
        }
    }

    private var settingsURL: URL {
        #if os(iOS)
            URL(string: UIApplication.openSettingsURLString)!
        #else
            URL(string: "x-apple.systempreferences:com.apple.systempreferences.AppleIDSettings")!
        #endif
    }
}

#Preview("Account Unavailable") {
    NavigationStack {
        AccountUnavailableView(issue: .temporarilyUnavailable, endpoint: "iCloud.com.northwind.shop", retry: {})
    }
}
