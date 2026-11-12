//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct SettingsLabel: View {
    let title: String

    var body: some View {
        Text(verbatim: title)
            .font(.scoutFootnoteStrong)
            .tracking(0.3)
            .foregroundStyle(Color.textMuted)
            .padding(.top, .space22)
            .padding(.bottom, .space8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SettingsNote: View {
    let text: String

    var body: some View {
        Text(verbatim: text)
            .font(.scoutCaption)
            .foregroundStyle(Color.textMuted)
            .padding(.top, .space4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
