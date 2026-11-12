//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension EventView {
    struct ParamSection: View {
        static let previewLimit = 3

        let count: Int

        @Environment(\.database) private var database
        @ObservedObject var param: ParamProvider
        @Binding var isParamPresented: Bool

        var body: some View {
            SectionHeader(title: "Params") {
                switch param.result {
                case .success where count > Self.previewLimit:
                    Button {
                        isParamPresented = true
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.blue)
                            .frame(width: 44, height: 44)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, -12)
                    .accessibilityLabel(Text(verbatim: "Show all"))
                case .success, .failure, nil:
                    EmptyView()
                }
            }

            switch param.result {
            case .success(let items):
                ForEach(items.prefix(Self.previewLimit)) { item in
                    ParamPreviewRow(item: item)
                }
            case .failure(let error):
                ErrorRow(description: error.localizedDescription) {
                    await param.fetchAgain(in: database)
                }
                .overlay(alignment: .bottom) {
                    Separator()
                }
            case nil:
                ForEach(0..<min(Self.previewLimit, count), id: \.self) { index in
                    ParamPreviewPlaceholder(index: index)
                }
            }
        }
    }

    struct ParamPreviewRow: View {
        let item: ParamProvider.Item

        var body: some View {
            let value = ParamValue(parsing: item.value)

            NavigationLink {
                ParamView(item: item)
            } label: {
                HStack(spacing: 13) {
                    ParamIcon(value: value)

                    Text(verbatim: item.key)
                        .font(.weight450(size: 17))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .fixedSize()
                        .layoutPriority(1)

                    Spacer(minLength: 0)

                    FadingText(text: value.summary)
                        .foregroundStyle(value.isContainer ? .secondary : .primary)
                }
                .lineLimit(1)
                .frame(height: .rowRegular)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .overlay(alignment: .bottom) {
                Separator()
            }
        }
    }

    struct ParamPreviewPlaceholder: View {
        let index: Int

        var body: some View {
            let delay = 0.48 + Double(index) * 0.08

            HStack(spacing: 13) {
                SkeletonBar(width: 20, height: 20, delay: delay, cornerRadius: 5)
                    .frame(width: 24, alignment: .leading)

                SkeletonBar(width: [72, 52, 91][index % 3], height: 11, delay: delay)

                Spacer(minLength: 0)

                SkeletonBar(width: 74, height: 11, delay: delay)
            }
            .frame(height: .rowRegular)
            .overlay(alignment: .bottom) {
                Separator()
            }
        }
    }

    struct FadingText: View {
        let text: String

        var body: some View {
            ViewThatFits(in: .horizontal) {
                label

                label
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .mask {
                        HStack(spacing: 0) {
                            Rectangle()
                            LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                                .frame(width: 48)
                        }
                    }
            }
        }

        private var label: some View {
            Text(verbatim: text)
                .font(.weight450(size: 16, design: .monospaced))
                .lineLimit(1)
                .fixedSize()
        }
    }
}
