//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AlertWatchPicker: View {
    let watch: AlertDraft.Watch
    let select: (AlertDraft.Watch) -> Void

    var body: some View {
        AlertCard {
            VStack(spacing: 0) {
                ForEach(AlertDraft.Watch.allCases.indices, id: \.self) { index in
                    let option = AlertDraft.Watch.allCases[index]

                    Button {
                        select(option)
                    } label: {
                        AlertWatchPickerRow(watch: option, isSelected: option == watch)
                    }
                    .buttonStyle(.plain)
                    .overlay(alignment: .bottom) {
                        if index < AlertDraft.Watch.allCases.count - 1 {
                            Separator()
                        }
                    }
                }
            }
        }
    }
}

struct AlertWatchPickerRow: View {
    let watch: AlertDraft.Watch
    let isSelected: Bool

    var body: some View {
        HStack(spacing: .space8) {
            VStack(alignment: .leading, spacing: .space2) {
                Text(verbatim: watch.title)
                    .font(isSelected ? .scoutRowStrong : .scoutRow)

                Text(verbatim: watch.detail)
                    .font(.scoutMicro)
                    .foregroundStyle(isSelected ? Color.textLink.opacity(0.75) : Color.textMuted)
            }

            Spacer(minLength: 0)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.scoutLabelCaps)
            }
        }
        .foregroundStyle(isSelected ? Color.fillAccent : Color.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: .rowSubtitle)
        .padding(.horizontal, .space8)
        .background(isSelected ? Color.surfaceSelected : Color.clear)
        .contentShape(Rectangle())
    }
}
