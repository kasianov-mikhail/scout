//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct DemoStartView: View {
    @State private var selection = 0

    var openScout: () -> Void = {}
    var addToApp: () -> Void = {}

    private let days = [
        DemoDay(title: "A calm day", detail: "1,212 users, no crashes since 3.2.0", bars: [6, 7, 6, 8, 7, 6, 7, 8, 6, 7, 6, 7], highlight: nil),
        DemoDay(title: "A bad release", detail: "3.2.1 crashes on checkout", bars: [6, 7, 6, 7, 8, 18, 24, 28, 22, 16, 10, 8], highlight: .init(range: 5...9, tone: .danger)),
        DemoDay(title: "An outage", detail: "The API is down for 40 minutes", bars: [7, 8, 7, 6, 28, 28, 28, 28, 7, 8, 7, 6], highlight: .init(range: 4...7, tone: .outage)),
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: "DEMO")
                    .font(.scoutFootnoteStrong)
                    .tracking(0.72)
                    .foregroundStyle(Color.textCaution)
                    .frame(height: 16)
                    .badgeStyle(fill: Color.tintCaution)
                    .overlay {
                        RoundedRectangle(cornerRadius: .radiusBadge)
                            .strokeBorder(Color.lineTintCaution, lineWidth: .hairline)
                    }

                Text(verbatim: "Pick a day to explore")
                    .font(.scoutHeadline)
                    .frame(height: 34, alignment: .leading)
                    .padding(.top, .space12)

                (Text(verbatim: "Each one is sample data from ")
                    + Text(verbatim: "northwind-shop").foregroundColor(Color.textPrimary)
                    + Text(verbatim: ", a made-up store. Same app, different trouble."))
                    .font(.scoutBody)
                    .lineSpacing(4)
                    .foregroundStyle(Color.textSecondary)
                    .frame(minHeight: 46, alignment: .top)
                    .padding(.top, .space8)

                VStack(spacing: .space10) {
                    ForEach(days.indices, id: \.self) { index in
                        Button {
                            selection = index
                        } label: {
                            DemoDayCard(day: days[index], isSelected: selection == index)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selection == index ? [.isSelected] : [])
                    }
                }
                .padding(.top, 14)
                .hapticFeedback(.selection, trigger: selection)

                Text(verbatim: "Switch the day any time in Settings.")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
                    .padding(.top, 14)
            }
            .padding(.top, 98)
            .padding(.horizontal, .gutter)

            Spacer(minLength: 0)

            VStack(spacing: .space6) {
                Button(action: openScout) {
                    Text(verbatim: "Open Scout")
                }
                .buttonStyle(.prominent)

                Button(action: addToApp) {
                    Text(verbatim: "Add Scout to your app")
                        .font(.scoutBody)
                        .foregroundStyle(Color.textLink)
                        .frame(maxWidth: .infinity)
                        .frame(height: .touchTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, .gutter)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surface)
        .dynamicTypeSize(.large)
        .ignoresSafeArea()
    }
}

struct DemoDay {
    enum Tone {
        case danger
        case outage
    }

    struct Highlight {
        let range: ClosedRange<Int>
        let tone: Tone
    }

    let title: String
    let detail: String
    let bars: [CGFloat]
    let highlight: Highlight?
}

#Preview("Demo Start") {
    DemoStartView()
}
