//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .settingsCardStyle()
    }
}

extension View {
    func settingsCardStyle() -> some View {
        clipShape(RoundedRectangle(cornerRadius: .radiusBlock, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: .radiusBlock, style: .continuous)
                    .stroke(Color.separator, lineWidth: 0.5)
            }
    }
}

struct SettingsReadoutRow: View {
    var value: String? = nil
    var caption: String? = nil
    var captionSkeletonWidth: CGFloat? = nil
    var skeletonWidth: CGFloat = 74

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: .space4) {
            if let value {
                Text(verbatim: value)
                    .font(.scoutNumberS)
            } else {
                SkeletonBar(width: skeletonWidth, height: 16, delay: 0)
            }

            if let caption {
                Text(verbatim: caption)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            } else if let captionSkeletonWidth {
                SkeletonBar(width: captionSkeletonWidth, height: 9, delay: 0)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, .space8)
        .padding(.vertical, .space10)
    }
}

struct SettingsCardAction: View {
    let title: String
    var color = Color.fillAccent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: title)
                .font(.scoutRowStrong)
                .foregroundStyle(color)
                .padding(.horizontal, .gutter)
                .frame(maxHeight: .infinity)
                .overlay(alignment: .leading) {
                    Separator(axis: .vertical)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
