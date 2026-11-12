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
            .font(.system(size: 12, weight: .semibold))
            .tracking(0.4)
            .foregroundStyle(Color(.systemGray))
            .padding(.top, 22)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SettingsNote: View {
    let text: String

    var body: some View {
        Text(verbatim: text)
            .font(.book(size: 13))
            .foregroundStyle(Color(.systemGray))
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
