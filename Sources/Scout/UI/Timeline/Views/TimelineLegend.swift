//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TimelineLegend: View {
    let rails: [Rail]
    @Binding var expanded: Rail?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(rails, id: \.self) { rail in
                        Button {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                expanded = (expanded == rail) ? nil : rail
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(rail.color)
                                    .frame(width: 8, height: 8)
                                Text(rail.label)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule().fill(rail.color.opacity(expanded == rail ? 0.25 : 0.10))
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
                    .font(.system(size: 13))
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
