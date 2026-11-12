//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct SettingsStrip<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 0) {
            content()
        }
        .settingsCardStyle()
    }
}

enum SettingsSegmentState: Equatable {
    case normal
    case error
    case loading
}

struct SettingsSegmentCell: View {
    let title: String
    var detail: String? = nil
    var state = SettingsSegmentState.normal
    let isSelected: Bool
    let showsDivider: Bool

    private var hasDetail: Bool {
        detail != nil || state == .loading
    }

    private var foreground: Color {
        if isSelected {
            return .fillAccent
        }
        if state == .error {
            return .textDanger
        }
        return .textPrimary
    }

    private var detailForeground: Color {
        if isSelected {
            return Color.fillAccent.opacity(0.75)
        }
        if state == .error {
            return .textDanger
        }
        return Color.fillLevel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: title)
                .font(isSelected ? .scoutRowStrong : .scoutRow)
                .foregroundStyle(foreground)
                .lineLimit(1)

            if hasDetail {
                if let detail, state != .loading {
                    Text(verbatim: detail)
                        .font(.scoutMicro)
                        .foregroundStyle(detailForeground)
                        .lineLimit(1)
                } else {
                    SkeletonBar(width: 46, height: 7, delay: 0)
                        .frame(height: 13)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: hasDetail ? .rowSubtitle : .rowTable)
        .padding(.horizontal, .space8)
        .background(isSelected ? Color.surfaceSelected : Color.clear)
        .overlay(alignment: .trailing) {
            if showsDivider {
                Separator(axis: .vertical)
            }
        }
        .contentShape(Rectangle())
    }
}
