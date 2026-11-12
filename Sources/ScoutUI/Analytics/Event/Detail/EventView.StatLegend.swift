//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension EventView {
    struct StatLegend: View {
        let usual: String

        var body: some View {
            HStack(spacing: .space12) {
                HStack(spacing: .space6) {
                    VerticalDash()
                        .frame(height: 12)
                    Text(verbatim: "usual pace · \(usual) a day")
                }

                HStack(spacing: .space6) {
                    RoundedRectangle(cornerRadius: .radiusBar)
                        .fill(Color.eventAboveUsual)
                        .frame(width: 10, height: 8)
                    Text(verbatim: "above usual")
                }

                HStack(spacing: .space6) {
                    Rectangle()
                        .fill(Color.textPrimary)
                        .frame(width: 1.5, height: 12)
                    Text(verbatim: "now")
                }
            }
            .font(.scoutFootnote)
            .foregroundStyle(Color.textMuted)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 30)
            .overlay(alignment: .bottom) {
                Separator()
            }
        }
    }

    struct StatLegendPlaceholder: View {
        var body: some View {
            SkeletonBar(width: 150, height: 9, delay: 1.12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 30)
                .overlay(alignment: .bottom) {
                    Separator()
                }
        }
    }

    struct VerticalDash: View {
        var body: some View {
            GeometryReader { proxy in
                Path { path in
                    path.move(to: CGPoint(x: 0.5, y: 0))
                    path.addLine(to: CGPoint(x: 0.5, y: proxy.size.height))
                }
                .stroke(Color.fillLevel, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
            }
            .frame(width: 1)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        EventView.StatLegend(usual: "5.4")
        EventView.StatLegendPlaceholder()
    }
    .padding(.horizontal, .gutter)
}
