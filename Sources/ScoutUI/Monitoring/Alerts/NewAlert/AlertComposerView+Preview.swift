//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

#Preview("One Screen") {
    let provider = AlertProvider()
    let backtest = AlertBacktestProvider(metric: .eventCount(name: "PaymentDeclined"))
    backtest.result = .success(.sample)

    return NavigationStack {
        AlertComposerView(
            provider: provider,
            draft: AlertDraft(watch: .eventSpike, eventName: "PaymentDeclined"),
            backtest: backtest
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        AlertComposerView(
            provider: AlertProvider(),
            draft: AlertDraft(watch: .eventSpike, eventName: "PaymentDeclined")
        )
    }
}
