//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var draft: FilterDraft

    init(query: Binding<EventQuery>) {
        _draft = StateObject(wrappedValue: FilterDraft(query: query))
    }

    var body: some View {
        VStack(spacing: 0) {
            FilterHeader(isApplyEnabled: draft.isApplyEnabled, close: dismiss.callAsFunction, apply: apply)

            ScrollView {
                VStack(alignment: .leading, spacing: .space22) {
                    FilterLevelsView(draft: draft)
                    FilterPeriodView(draft: draft)
                    FilterContextView(draft: draft)
                }
                .padding(.horizontal, .gutter)
                .padding(.top, .space22)
                .padding(.bottom, .space16)
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                resetBar
            }
        }
        .background(Color.surface.ignoresSafeArea())
        #if os(macOS)
            .frame(minWidth: 390, minHeight: 560)
        #endif
    }

    private var resetBar: some View {
        Button(action: draft.reset) {
            Text(verbatim: "Reset Filter")
                .font(.scoutRowStrong)
                .foregroundStyle(Color.filterDestructive)
                .frame(maxWidth: .infinity)
                .frame(height: 47)
                .background(Color.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: .radiusBlock)
                        .strokeBorder(Color.lineSeparator, lineWidth: 0.5)
                }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, .gutter)
        .background(Color.surface)
        .accessibilityLabel(Text(verbatim: "Reset Filter"))
    }

    private func apply() {
        draft.apply()
        dismiss()
    }
}

#Preview("Filter Form") {
    FilterView(
        query: .constant(
            EventQuery(
                levels: [.error, .critical],
                sessionID: UUID()
            )
        )
    )
}
