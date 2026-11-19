//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

#Preview("Edit") {
    let provider = AlertProvider()
    let backtest = AlertBacktestProvider(metric: .crashFreeSessions)
    backtest.result = .success(.crashFreeSample)

    return NavigationStack {
        AlertDetailView(
            provider: provider,
            rule: AlertStatus.firingSample.rule,
            status: .firingSample,
            backtest: backtest
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        AlertDetailView(
            provider: AlertProvider(),
            rule: AlertStatus.firingSample.rule
        )
    }
}
