//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Legend: View {
    let kinds: [LegendKind]
    @Binding var expanded: LegendKind?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(kinds, id: \.self) { kind in
                        Button {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                expanded = (expanded == kind) ? nil : kind
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(kind.color)
                                    .frame(width: 8, height: 8)
                                Text(kind.label)
                                    .font(.fixedFootnote)
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule().fill(kind.color.opacity(expanded == kind ? 0.25 : 0.10))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            if let expanded {
                Text(expanded.legendDescription)
                    .font(.fixedFootnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Divider()
        }
    }
}
