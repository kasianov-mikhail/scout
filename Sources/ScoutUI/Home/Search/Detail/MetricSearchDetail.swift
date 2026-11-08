//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct MetricSearchDetail: View {
    let name: String
    let telemetry: Telemetry.Export

    var body: some View {
        MetricDetailView(name: name, telemetry: telemetry, range: .today)
    }
}
