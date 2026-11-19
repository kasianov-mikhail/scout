//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct IncidentCulpritCard<Element: Incident & IncidentDetailInfo>: View {
    let element: Element
    let culprit: IncidentStackRow
    let caller: IncidentStackRow?

    var body: some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: element.detailCulprit)
                .font(.scoutFootnote)
                .foregroundStyle(Color.textMuted)

            if let symbol = culprit.symbol {
                Text(verbatim: symbol)
                    .font(.scoutNavEvent)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let location = culprit.location {
                Text(verbatim: location.text)
                    .font(.scoutCode)
                    .foregroundStyle(Element.kind.detailColor)
            }

            if let caller, let callerSymbol = caller.bareSymbol, let callerLocation = caller.location {
                (Text(verbatim: "called from ")
                    + Text(verbatim: callerSymbol).font(.scoutCode).foregroundColor(Color.textPrimary)
                    + Text(verbatim: " · line \(callerLocation.line)"))
                    .font(.scoutFootnote)
                    .foregroundStyle(Color.textMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .space12)
        .padding(.vertical, .space12)
        .background {
            RoundedRectangle(cornerRadius: .radiusBlock)
                .fill(Color.surfaceGrey)
        }
    }
}
