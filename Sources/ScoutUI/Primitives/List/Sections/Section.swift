//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Section<Header: View, Content: View>: View {
    let insetsContent: Bool
    let bottomGap: CGFloat

    @ViewBuilder let header: () -> Header
    @ViewBuilder let content: () -> Content

    init(insetsContent: Bool = true, bottomGap: CGFloat = .space6, @ViewBuilder header: @escaping () -> Header, @ViewBuilder content: @escaping () -> Content) {
        self.insetsContent = insetsContent
        self.bottomGap = bottomGap
        self.header = header
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionGap()

            header()
                .padding(.horizontal, .gutter)

            content()
                .padding(.horizontal, insetsContent ? .gutter : 0)
        }
        .padding(.bottom, bottomGap)
    }
}

extension Section {
    init<Trailing: View>(title: String, showsSeparator: Bool = true, insetsContent: Bool = true, bottomGap: CGFloat = .space6, @ViewBuilder trailing: @escaping () -> Trailing, @ViewBuilder content: @escaping () -> Content) where Header == SectionHeader<Trailing> {
        self.init(insetsContent: insetsContent, bottomGap: bottomGap) {
            SectionHeader(title: title, showsSeparator: showsSeparator, trailing: trailing)
        } content: {
            content()
        }
    }
}

extension Section where Header == SectionHeader<EmptyView> {
    init(title: String, showsSeparator: Bool = true, insetsContent: Bool = true, bottomGap: CGFloat = .space6, @ViewBuilder content: @escaping () -> Content) {
        self.init(insetsContent: insetsContent, bottomGap: bottomGap) {
            SectionHeader(title: title, showsSeparator: showsSeparator)
        } content: {
            content()
        }
    }
}

extension Section where Header == SectionHeader<Text> {
    init(title: String, note: String, insetsContent: Bool = true, bottomGap: CGFloat = .space6, @ViewBuilder content: @escaping () -> Content) {
        self.init(insetsContent: insetsContent, bottomGap: bottomGap) {
            SectionHeader(title: title) {
                Text(verbatim: note)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }
        } content: {
            content()
        }
    }
}

#Preview {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            Section(title: "SESSIONS") {
                ForEach(0..<3, id: \.self) { index in
                    Text(verbatim: "Session \(index)")
                        .frame(height: .rowRegular)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Section(title: "HISTORY", note: "last seen") {
                Text(verbatim: "Row")
                    .frame(height: .rowRegular)
            }

            Section(bottomGap: .space18) {
                SectionHeader(titles: ["TELEMETRY", "INCIDENTS"])
            } content: {
                Text(verbatim: "Grid")
                    .frame(height: 66)
            }
        }
    }
    .scrollIndicators(.hidden)
}
