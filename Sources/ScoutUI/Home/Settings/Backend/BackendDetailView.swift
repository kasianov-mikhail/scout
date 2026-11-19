//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct BackendDetailView: View {
    @ObservedObject var provider: BackendHealthProvider
    let id: String
    @Binding var activeID: String

    @Environment(\.openURL) private var openURL

    @State private var copyCount = 0

    var report = BackendReport()

    private var backend: BackendHealth? {
        provider.backends.first { $0.id == id }
    }

    var body: some View {
        Group {
            if let backend {
                content(for: backend)
            } else {
                ErrorView(description: "This backend is no longer available.", retry: nil)
            }
        }
        .navigationTitle(en: backend?.name ?? "Backend")
        .inlineNavigationTitle()
    }

    private func content(for backend: BackendHealth) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    SettingsLabel(title: "STATUS")

                    SettingsCard {
                        SettingsReadoutRow(
                            value: backend.status == nil ? nil : backend.status.healthLabel,
                            caption: report.statusDetail,
                            captionSkeletonWidth: backend.status == nil ? 120 : nil,
                            skeletonWidth: 120
                        )
                    }

                    SettingsLabel(title: backend.isCloud ? "CONTAINER" : "ADDRESS")

                    SettingsCard {
                        SettingsAddressRow(value: backend.endpoint) {
                            copy(backend.endpoint)
                        }

                        addressColumns(for: backend)
                    }

                    SettingsLabel(title: "LATEST DATA")

                    SettingsCard {
                        SettingsReadoutRow(
                            value: report.latestEvent,
                            caption: report.latestEvent == nil ? nil : (backend.isCloud ? "newest event in CloudKit" : "newest event on the server"),
                            captionSkeletonWidth: report.latestEvent == nil ? 74 : nil
                        )
                    }

                    SettingsLabel(title: "THIS IPHONE SENDS")

                    SettingsCard {
                        SettingsReadoutRow(
                            value: report.pendingRecords,
                            caption: report.pendingRecords == nil ? nil : "records waiting",
                            captionSkeletonWidth: report.pendingRecords == nil ? 74 : nil,
                            skeletonWidth: 28
                        )

                        SettingsColumnRow {
                            SettingsColumn(title: "Last sent", value: report.lastSent)
                            SettingsColumn(title: "Given up", value: report.givenUp)
                            SettingsColumn(title: "Last error", value: report.lastError, isLast: true)
                        }
                    }

                    SettingsLabel(title: "STORAGE")

                    storageCard(for: backend)

                    if backend.isCloud {
                        SettingsNote(text: "CloudKit does not report its size to apps. The exact number is in CloudKit Console.")
                    }

                    errorsSection(for: backend)

                    if case .server = backend.engine {
                        BackendRetentionSection(id: backend.id)
                    }

                    SettingsButton(
                        title: backend.id == activeID ? "Reading From \(backend.name)" : "Read From \(backend.name)",
                        isEnabled: backend.id != activeID
                    ) {
                        activeID = backend.id
                    }
                    .padding(.top, 26)
                }
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
        .hapticFeedback(.success, trigger: copyCount)
    }

    private func copy(_ text: String) {
        #if os(iOS)
            UIPasteboard.general.string = text
        #else
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
        #endif
        copyCount += 1
    }

    func openConsole() {
        if let url = URL(string: "https://icloud.developer.apple.com/dashboard/") {
            openURL(url)
        }
    }
}
