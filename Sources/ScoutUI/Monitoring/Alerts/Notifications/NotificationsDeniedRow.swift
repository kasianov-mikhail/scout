//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct NotificationsDeniedRow: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.slash")
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "Notifications are off")
                    .font(.callout)

                Text(verbatim: "Firing rules won't reach this device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let settingsURL {
                Button {
                    openURL(settingsURL)
                } label: {
                    Text(verbatim: "Settings")
                }
                .buttonStyle(.borderless)
            }
        }
        .frame(minHeight: 44)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
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
    InsetList {
        Header(title: "Rules")
        NotificationsDeniedRow()
    }
}
