//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct SettingsAddressRow: View {
    let value: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text(verbatim: value)
                .font(.scoutRowMono)
                .padding(.horizontal, .space8)
                .padding(.vertical, .space10)
                .frame(maxWidth: .infinity, alignment: .leading)

            SettingsCardAction(title: "Copy", action: action)
        }
    }
}

struct SettingsColumnRow<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 0) {
            content()
        }
        .overlay(alignment: .top) {
            Separator()
        }
    }
}
