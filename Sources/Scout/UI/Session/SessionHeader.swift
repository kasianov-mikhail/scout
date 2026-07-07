//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SessionHeader: View {
    let info: SessionInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FlowLayout(spacing: 6) {
                if let model = info.model {
                    InfoChip(systemImage: "iphone", text: model, color: .blue)
                }
                if let osVersion = info.osVersion {
                    InfoChip(systemImage: "gearshape", text: osVersion, color: .indigo)
                }
                if let locale = info.locale {
                    InfoChip(systemImage: "globe", text: locale, color: .teal, monospaced: true)
                }
                if let channel = info.channel {
                    InfoChip(systemImage: info.channelIcon, text: channel, color: info.channelColor)
                }
                if let version = info.version {
                    InfoChip(systemImage: "tag", text: version, color: .green, monospaced: true)
                }
            }

            if let subtitle {
                Text(verbatim: subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .listRowSeparator(.hidden)
    }

    private var subtitle: String? {
        var parts: [String] = []
        if let duration = info.duration {
            parts.append(duration)
        }
        if let startDate = info.startDate {
            parts.append("started \(startDate.relativeString)")
        }
        return parts.count > 0 ? parts.joined(separator: " · ") : nil
    }
}

#Preview {
    List {
        SessionHeader(info: .sample)
    }
    .listStyle(.plain)
}
