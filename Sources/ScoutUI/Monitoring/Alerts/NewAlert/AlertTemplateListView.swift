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
                        .font(.system(size: 28, weight: .bold))
                        .padding(.top, 20)

                    Text(verbatim: "Pick a starting point. You can change everything on the next step.")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.systemGray))
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                    AlertDivider()

                    ForEach(AlertDraft.Watch.allCases.indices, id: \.self) { index in
                        let watch = AlertDraft.Watch.allCases[index]

                        NavigationLink(value: watch) {
                            AlertTemplateRow(watch: watch)
                        }
                        .buttonStyle(.plain)

                        if index < AlertDraft.Watch.allCases.count - 1 {
                            AlertDivider()
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemBackground))
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
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 20))
                .foregroundStyle(tint)
                .frame(width: 32, alignment: .leading)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                Text(verbatim: watch.templateTitle)
                    .font(.system(size: 17, weight: .semibold))

                Text(verbatim: watch.templateDetail)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.systemGray))
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 14)
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
        watch == .crashFreeDrop ? .red : .blue
    }
}

#Preview {
    AlertTemplateListView(provider: AlertProvider())
}
