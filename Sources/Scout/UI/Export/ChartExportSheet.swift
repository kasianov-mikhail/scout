//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ChartExportSheet<ChartContent: View>: View {
    let title: String
    let rangeLabel: String

    @ViewBuilder let chart: () -> ChartContent

    @State private var options = ChartExportOptions()
    @State private var fileURL: URL?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        List {
            ChartSnapshot(title: title, rangeLabel: rangeLabel, showsTitle: options.includesTitle, showsRange: options.includesRange, fadesHeader: true, chart: chart)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())

            Header(title: "Format")
                .listRowSeparator(.hidden, edges: .top)

            HStack {
                Text(verbatim: "File Type")
                Spacer()
                Picker(selection: $options.format) {
                    ForEach(ChartExportFormat.allCases) { format in
                        Text(verbatim: format.rawValue).tag(format)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }
            .frame(height: 22)

            HStack {
                Text(verbatim: "Appearance")
                Spacer()
                Picker(selection: $options.appearance) {
                    ForEach(ChartExportAppearance.allCases) { appearance in
                        Text(verbatim: appearance.rawValue).tag(appearance)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.menu)
            }
            .frame(height: 22)
            .listRowSeparator(.visible, edges: .bottom)

            Header(title: "Content")
                .listRowSeparator(.hidden, edges: .top)

            Toggle(isOn: $options.includesTitle) {
                Text(verbatim: "Chart Title")
            }

            Toggle(isOn: $options.includesRange) {
                Text(verbatim: "Period Label")
            }
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .bottom) {
            shareButton.padding()
        }
        .task(id: options) {
            fileURL = exportURL()
        }
        .navigationTitle(en: "Export Image")
        .inlineNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text(verbatim: "Cancel")
                }
            }
        }
    }

    @ViewBuilder private var shareButton: some View {
        if #available(iOS 26, macOS 26, *) {
            glassShareButton
        } else if let fileURL {
            ShareLink(item: fileURL) {
                Text(verbatim: "Share Image")
            }
            .buttonStyle(.pill)
        }
    }

    @available(iOS 26, macOS 26, *)
    @ViewBuilder private var glassShareButton: some View {
        if let fileURL {
            ShareLink(item: fileURL) {
                Text(verbatim: "Share Image")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.glassProminent)
            .tint(.blue)
        }
    }

    private func exportURL() -> URL? {
        guard let data = ChartExportRenderer.data(for: exportView, format: options.format, scale: displayScale) else {
            return nil
        }
        let file = ChartExportFile(data: data, name: title, format: options.format)
        return try? file.write()
    }

    private var exportView: some View {
        let scheme = options.appearance.resolvedScheme(current: colorScheme)

        return ChartSnapshot(title: title, rangeLabel: rangeLabel, showsTitle: options.includesTitle, showsRange: options.includesRange, chart: chart)
            .frame(width: ChartExportRenderer.width)
            .background(scheme == .dark ? Color.black : Color.white)
            .environment(\.colorScheme, scheme)
    }
}

#Preview("Chart Export Sheet") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                ChartExportSheet(title: "app_launch", rangeLabel: "Jun 2 – Jul 2, 2026") {
                    ChartView(segment: .sample, timing: ChartExtent(period: Period.month))
                }
            }
        }
}
