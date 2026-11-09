//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ServiceUnavailableView: View {
    var endpoint = "scout.northwind-shop.dev"
    var retry: () -> Void = {}

    var body: some View {
        ErrorCodeScreen(
            code: "503",
            title: "Service Unavailable",
            message: "The Scout server is up but can't take requests right now. Events stay on the devices and upload later.",
            endpoint: endpoint,
            retry: retry
        )
    }
}

#Preview("Service Unavailable") {
    NavigationStack {
        ServiceUnavailableView()
    }
}
