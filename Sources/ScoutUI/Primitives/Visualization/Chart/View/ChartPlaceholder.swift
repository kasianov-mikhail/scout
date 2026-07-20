//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

/// "No results" placeholder shown over an empty chart's plot area.
struct ChartPlaceholder: View {
    var body: some View {
        Text(verbatim: "No results")
            .placeholderTextStyle()
    }
}
