//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AlertListLegend: View {
    var showsAxis = true

    var body: some View {
        VStack(alignment: .leading, spacing: .space4) {
            HStack {
                Text(verbatim: "24 h ago")
                Spacer()
                Text(verbatim: "12 h")
                Spacer()
                Text(verbatim: "now")
            }
            .font(.scoutAxis)
            .foregroundStyle(Color.textMuted)
            .opacity(showsAxis ? 1 : 0)

            HStack(spacing: .space12) {
                legendItem(color: Color.fillLevel, title: "breached")
                legendItem(color: Color.textDanger, title: "firing now")
            }
            .font(.scoutFootnote)
            .foregroundStyle(Color.textMuted)
        }
        .padding(.bottom, .space16)
    }

    private func legendItem(color: Color, title: String) -> some View {
        HStack(spacing: .space4) {
            RoundedRectangle(cornerRadius: .radiusBar)
                .fill(color)
                .frame(width: 10, height: 10)

            Text(verbatim: title)
        }
    }
}
