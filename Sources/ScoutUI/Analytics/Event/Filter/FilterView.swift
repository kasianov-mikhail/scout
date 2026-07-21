//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var draft: FilterDraft

    init(query: Binding<EventQuery>) {
        _draft = StateObject(wrappedValue: FilterDraft(query: query))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    FilterLevelsView(draft: draft)
                    FilterPeriodView(draft: draft)
                    FilterContextView(draft: draft)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel(Text(verbatim: "Cancel"))
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        draft.reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .tint(.red)
                    .disabled(!draft.isResetEnabled)
                    .accessibilityLabel(Text(verbatim: "Reset"))
                    Button {
                        draft.apply()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .tint(.green)
                    .disabled(!draft.isApplyEnabled)
                    .fontWeight(.semibold)
                    .accessibilityLabel(Text(verbatim: "Apply"))
                }
            }
            .navigationTitle(en: "Filter")
            .inlineNavigationTitle()
        }
    }
}

extension View {
    func softCell(selected: Bool = false, tint: Color = .blue) -> some View {
        padding(12).background(
            tint.opacity(selected ? 0.1 : 0.04),
            in: RoundedRectangle(cornerRadius: 12)
        )
    }
}

#Preview("Filter Form") {
    FilterView(
        query: .constant(
            EventQuery(
                levels: [.error, .critical],
                dates: Date().startOfDay.addingDay(-7)..<Date().startOfDay
            )
        )
    )
}
