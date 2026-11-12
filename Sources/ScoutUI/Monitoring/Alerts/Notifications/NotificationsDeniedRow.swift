//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct NotificationsDeniedRow: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(spacing: .space12) {
            Image(systemName: "bell.slash")
                .font(.book(size: 20))
                .foregroundStyle(Color.textWarning)

            VStack(alignment: .leading, spacing: .space2) {
                Text(verbatim: "Notifications are off")
                    .font(.scoutRow)

                Text(verbatim: "Firing rules won't reach this device.")
                    .font(.scoutFootnote)
                    .foregroundStyle(Color.textMuted)
            }

            Spacer()

            if let settingsURL {
                Button {
                    openURL(settingsURL)
                } label: {
                    Text(verbatim: "Settings")
                        .font(.scoutRow)
                }
                .buttonStyle(.borderless)
            }
        }
        .frame(height: 60)
    }

    private var settingsURL: URL? {
        #if os(iOS)
            URL(string: UIApplication.openSettingsURLString)
        #else
            nil
        #endif
    }
}

#Preview {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            Header(title: "Rules")
            NotificationsDeniedRow()
        }
        .padding(.horizontal, .gutter)
    }
    .scrollIndicators(.hidden)
}
