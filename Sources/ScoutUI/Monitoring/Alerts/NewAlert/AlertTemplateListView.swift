//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AlertTemplateListView: View {
    @ObservedObject var provider: AlertProvider

    @State private var path: [AlertDraft.Watch] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(verbatim: "What should Scout watch?")
                        .font(.listTitle)
                        .padding(.top, .space20)

                    Text(verbatim: "Pick a starting point. You can change everything on the next step.")
                        .font(.scoutRow)
                        .foregroundStyle(Color.textMuted)
                        .padding(.top, .space8)
                        .padding(.bottom, .space8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(alignment: .bottom) {
                            AlertDivider()
                        }

                    ForEach(AlertDraft.Watch.allCases.indices, id: \.self) { index in
                        let watch = AlertDraft.Watch.allCases[index]

                        NavigationLink(value: watch) {
                            AlertTemplateRow(watch: watch)
                        }
                        .buttonStyle(.plain)
                        .overlay(alignment: .bottom) {
                            if index < AlertDraft.Watch.allCases.count - 1 {
                                AlertDivider()
                            }
                        }
                    }
                }
                .padding(.horizontal, .gutter)
            }
            .scrollIndicators(.hidden)
            .background(Color.surface)
            .navigationTitle(en: "New Alert")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AlertCloseButton {
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: AlertDraft.Watch.self) { watch in
                AlertFormView(
                    provider: provider,
                    draft: AlertDraft(watch: watch),
                    onClose: { dismiss() },
                    onChangeWatch: { path.removeLast() },
                    onSaved: {
                        path.removeAll()
                        dismiss()
                    }
                )
            }
        }
    }
}

private struct AlertTemplateRow: View {
    let watch: AlertDraft.Watch

    var body: some View {
        HStack(alignment: .top, spacing: .space12) {
            Image(systemName: symbol)
                .font(.book(size: 20))
                .foregroundStyle(tint)
                .frame(width: 32, alignment: .leading)
                .padding(.top, .space2)

            VStack(alignment: .leading, spacing: .space2) {
                Text(verbatim: watch.templateTitle)
                    .font(.scoutTitle)

                Text(verbatim: watch.templateDetail)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, .space12)
        .contentShape(Rectangle())
    }

    private var symbol: String {
        switch watch {
        case .crashFreeDrop:
            "exclamationmark.triangle"
        case .eventSpike:
            "chart.line.uptrend.xyaxis"
        case .eventSilence:
            "chart.line.downtrend.xyaxis"
        case .eventCount:
            "chart.xyaxis.line"
        }
    }

    private var tint: Color {
        watch == .crashFreeDrop ? Color.textDanger : Color.textLink
    }
}

#Preview {
    AlertTemplateListView(provider: AlertProvider())
}
