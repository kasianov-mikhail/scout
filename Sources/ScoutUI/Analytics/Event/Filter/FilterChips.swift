//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct FilterChips: View {
    @Binding var query: EventQuery

    var body: some View {
        let chips = query.chips

        if !chips.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .space8) {
                    ForEach(chips) { chip in
                        Button {
                            withAnimation {
                                query.remove(chip.kind)
                            }
                        } label: {
                            HStack(spacing: .space4) {
                                Text(verbatim: chip.label)
                                Image(systemName: "xmark")
                                    .imageScale(.small)
                            }
                            .font(.scoutFootnote)
                            .foregroundStyle(Color.textLink)
                            .padding(.horizontal, .space10)
                            .padding(.vertical, .space6)
                            .background(Color.fillAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: .radiusBlock))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, .space8)
            }
        }
    }
}

#Preview {
    FilterChips(
        query: .constant(
            EventQuery(
                levels: [.error, .critical],
                sessionID: UUID(),
                deviceID: UUID(),
                dates: Date().startOfDay.addingDay(-7)..<Date().startOfDay
            )
        )
    )
}
