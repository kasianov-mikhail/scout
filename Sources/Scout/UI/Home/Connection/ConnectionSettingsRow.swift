//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ConnectionSettingsRow: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .imageScale(.medium)
                    .foregroundStyle(.secondary)
                Text(verbatim: "Settings")
                    .font(.fixedCallout)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.top, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ConnectionSettingsRow(action: {})
        .frame(minWidth: 240)
}
