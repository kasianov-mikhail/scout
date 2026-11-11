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
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    VerticalDash()
                        .frame(height: 12)
                    Text(verbatim: "usual pace · \(usual) a day")
                }

                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.eventAboveUsual)
                        .frame(width: 10, height: 8)
                    Text(verbatim: "above usual")
                }

                HStack(spacing: 6) {
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 1.5, height: 12)
                    Text(verbatim: "now")
                }
            }
            .font(.weight450(size: 12))
            .foregroundStyle(Color(.systemGray))
            .lineLimit(1)
            .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30, alignment: .leading)
            .overlay(alignment: .bottom) {
                Separator()
            }
        }
    }

    struct StatLegendPlaceholder: View {
        var body: some View {
            SkeletonBar(width: 150, height: 9, delay: 1.12)
                .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30, alignment: .leading)
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
                .stroke(Color(.systemGray), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
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
    .padding(.horizontal, 16)
}
