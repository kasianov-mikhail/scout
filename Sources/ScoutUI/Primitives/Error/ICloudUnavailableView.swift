//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ICloudUnavailableView: View {
    var container = "iCloud.com.northwind.shop"
    var retry: () -> Void = {}

    var body: some View {
        ErrorCodeScreen(
            code: "6",
            cloud: true,
            title: "iCloud Is Unavailable",
            message: "CloudKit can't take requests right now. Events stay on the devices and upload later.",
            endpoint: container,
            retry: retry
        )
    }
}

#Preview("iCloud Unavailable") {
    NavigationStack {
        ICloudUnavailableView()
    }
}
