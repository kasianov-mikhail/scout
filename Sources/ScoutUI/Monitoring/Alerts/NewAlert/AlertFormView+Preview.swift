//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

#Preview("Form") {
    let provider = AlertProvider()
    let backtest = AlertBacktestProvider(metric: .eventCount(name: "PaymentDeclined"))
    backtest.result = .success(.sample)

    return NavigationStack {
        AlertFormView(
            provider: provider,
            draft: AlertDraft(watch: .eventSpike, eventName: "PaymentDeclined"),
            onClose: {},
            onChangeWatch: {},
            onSaved: {},
            backtest: backtest
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        AlertFormView(
            provider: AlertProvider(),
            draft: AlertDraft(watch: .eventSpike, eventName: "PaymentDeclined"),
            onClose: {},
            onChangeWatch: {},
            onSaved: {}
        )
    }
}
