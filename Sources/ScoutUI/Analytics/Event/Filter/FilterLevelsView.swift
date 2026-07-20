//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct FilterLevelsView: View {
    @ObservedObject var draft: FilterDraft

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Header(title: "Levels")

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(EventLevel.allCases, id: \.rawValue) { level in
                    let on = draft.isSelected(level)
                    HStack {
                        Image(systemName: on ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(on ? (level.color ?? .blue) : Color(.systemGray3))
                        Text(level.description).font(.callout)
                        Spacer()
                    }
                    .padding(12)
                    .softCell(selected: on, tint: level.color ?? .blue)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        draft.toggle(level)
                    }
                }
            }
        }
    }
}
