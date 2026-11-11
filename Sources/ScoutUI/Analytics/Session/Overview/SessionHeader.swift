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
        VStack(spacing: 0) {
            summary
                .padding(.top, 16)
                .padding(.bottom, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .bottom) {
                    divider
                }

            chips
                .padding(.top, 12)
                .padding(.bottom, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .bottom) {
                    divider
                }
        }
    }

    @ViewBuilder
    private var summary: some View {
        if let duration = info.duration, let detail = info.detail {
            (Text(verbatim: duration).font(.system(size: 15, weight: .semibold)) + Text(verbatim: " · \(detail)"))
                .font(.weight450(size: 15))
        } else if let text = info.summary {
            Text(verbatim: text)
                .font(.weight450(size: 15))
        }
    }

    private var chips: some View {
        FlowLayout(spacing: 6) {
            if let model = info.model.map(DeviceModel.init) {
                OutlineChip(text: model.name)
            }
            if let osVersion = info.osVersion {
                OutlineChip(text: osVersion)
            }
            if let locale = info.locale {
                OutlineChip(text: locale, monospaced: true)
            }
            if let version = info.version {
                OutlineChip(text: version, monospaced: true)
            }
            if let channel = info.channel {
                OutlineChip(text: channel)
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(.systemGray3))
            .frame(height: 0.5)
            .padding(.horizontal, 16)
    }
}

#Preview {
    SessionHeader(info: .sample)
        .padding(.vertical)
}
