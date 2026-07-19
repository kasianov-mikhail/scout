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

        if chips.count > 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chips) { chip in
                        Button {
                            withAnimation {
                                query.remove(chip.kind)
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Text(verbatim: chip.label)
                                Image(systemName: "xmark")
                                    .imageScale(.small)
                            }
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.13), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
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
