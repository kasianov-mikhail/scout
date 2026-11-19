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

    @Environment(\.openURL) private var openURL

    var body: some View {
        ErrorCodeScreen(cloud: true, title: issue.title, message: issue.localizedDescription, endpoint: endpoint) {
            Button {
                openURL(settingsURL)
            } label: {
                Text(verbatim: "Open Settings")
            }
            .buttonStyle(ErrorActionButtonStyle(role: .primary))
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
        AccountUnavailableView(issue: .temporarilyUnavailable, endpoint: "iCloud.com.northwind.shop")
    }
}
