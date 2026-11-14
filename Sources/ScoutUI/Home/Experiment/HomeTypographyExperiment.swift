//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct HomeTypographyExperiment {
    static let storageKey = "scout_home_typography"

    static var isAvailable: Bool {
        #if DEBUG
            true
        #elseif targetEnvironment(simulator)
            true
        #else
            isAvailable(
                receiptName: Bundle.main.appStoreReceiptURL?.lastPathComponent,
                isDebug: false,
                isSimulator: false
            )
        #endif
    }

    static func isAvailable(receiptName: String?, isDebug: Bool, isSimulator: Bool) -> Bool {
        isDebug || isSimulator || receiptName == "sandboxReceipt"
    }

    /// The App Store build always renders V01, even when a TestFlight tester
    /// previously picked another variant on the same install.
    static func selection(stored: String, available: Bool) -> HomeTypography {
        guard available else {
            return .v01
        }
        return HomeTypography.variant(id: stored)
    }
}
