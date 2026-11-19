//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct IncidentSummaryFrameRow: View {
    let frame: IncidentStackFrame

    var body: some View {
        HStack(spacing: .space6) {
            Text(verbatim: frame.index)
                .frame(width: 18, alignment: .leading)

            Text(verbatim: frame.image ?? "")
                .frame(width: 128, alignment: .leading)

            Text(verbatim: frame.symbol)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fadingEdge(width: 28)
        }
        .font(frame.isApp ? .scoutCodeStrong : .scoutCode)
        .foregroundStyle(frame.isApp ? Color.textPrimary : Color.fillLevel)
        .lineLimit(1)
        .frame(height: .codeStep)
    }
}
