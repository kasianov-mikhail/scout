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
                        Text(verbatim: "Cancel")
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        draft.reset()
                    } label: {
                        Text(verbatim: "Reset")
                    }
                    .disabled(!draft.isResetEnabled)
                    Button {
                        draft.apply()
                        dismiss()
                    } label: {
                        Text(verbatim: "Apply")
                    }
                    .disabled(!draft.isApplyEnabled)
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle(en: "Filter")
            .inlineNavigationTitle()
        }
        .modalFrame(height: draft.isDateRangeEnabled ? 720 : 600)
    }
}

extension View {
    func softCell(selected: Bool = false, tint: Color = .blue) -> some View {
        background(tint.opacity(selected ? 0.1 : 0.04), in: RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    @ViewBuilder
    fileprivate func modalFrame(height: CGFloat) -> some View {
        #if os(iOS)
            self
        #else
            frame(width: height / 1.618, height: height)
        #endif
    }
}

#Preview("Filter Form") {
    Color.clear.sheet(isPresented: .constant(true)) {
        FilterView(
            query: .constant(
                EventQuery(
                    levels: [.error, .critical],
                    dates: Date().startOfDay.addingDay(-7)..<Date().startOfDay
                )
            )
        )
    }
}
