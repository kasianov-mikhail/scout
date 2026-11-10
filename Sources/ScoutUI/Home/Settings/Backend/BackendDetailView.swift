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

    @State private var retention = BackendRetention.year
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
        InsetList {
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
                        caption: backend.isCloud ? "newest event in CloudKit" : "newest event on the server"
                    )
                }

                SettingsLabel(title: "THIS IPHONE SENDS")

                SettingsCard {
                    SettingsReadoutRow(
                        value: report.pendingRecords,
                        caption: "records waiting",
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
                    retentionSection
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
        .hapticFeedback(.success, trigger: copyCount)
    }

    @ViewBuilder
    private func addressColumns(for backend: BackendHealth) -> some View {
        SettingsColumnRow {
            switch backend.engine {
            case .cloudKit:
                SettingsColumn(title: "Database", value: report.database)
                SettingsColumn(title: "Schema", value: report.schema)
                SettingsColumn(title: report.symbolsTitle, value: report.symbolsState, isLast: true)
            case let .server(info):
                SettingsColumn(title: "Transport", value: info.isSecure ? "HTTPS" : "HTTP")
                SettingsColumn(title: "API key", value: info.hasAPIKey ? "Set" : "Not set")
                SettingsColumn(title: report.symbolsTitle, value: report.symbolsState, isLast: true)
            case .local:
                SettingsColumn(title: "Transport", value: "On Device")
                SettingsColumn(title: "API key", value: "Not set")
                SettingsColumn(title: report.symbolsTitle, value: report.symbolsState, isLast: true)
            }
        }
    }

    @ViewBuilder
    private func storageCard(for backend: BackendHealth) -> some View {
        SettingsCard {
            if backend.isCloud {
                HStack(spacing: 0) {
                    SettingsReadoutRow(
                        value: report.storage,
                        caption: report.storageCaption,
                        captionSkeletonWidth: report.storageCaption == nil ? 74 : nil
                    )

                    SettingsCardAction(title: "Console") {
                        openConsole()
                    }
                }
            } else {
                SettingsReadoutRow(
                    value: report.storage,
                    caption: report.storageCaption,
                    captionSkeletonWidth: report.storageCaption == nil ? 74 : nil
                )

                SettingsColumnRow {
                    SettingsColumn(title: "Events", value: report.eventCount)
                    SettingsColumn(title: "Sessions", value: report.sessionCount)
                    SettingsColumn(title: "Metrics", value: report.metricCount, isLast: true)
                }
            }
        }
    }

    @ViewBuilder
    private func errorsSection(for backend: BackendHealth) -> some View {
        if backend.isCloud {
            SettingsLabel(title: "SEND ERRORS · 24 H")

            SettingsCard {
                SettingsReadoutRow(
                    value: report.sendErrors,
                    caption: "devices could not send",
                    skeletonWidth: 28
                )
            }

            SettingsNote(text: "Reported by devices once they reach iCloud again. CloudKit itself does not share its error rate.")
        } else {
            SettingsLabel(title: "INTAKE ERRORS · 24 H")

            SettingsCard {
                SettingsReadoutRow(
                    value: report.errorRate,
                    caption: report.requestCount,
                    captionSkeletonWidth: report.requestCount == nil ? 120 : nil,
                    skeletonWidth: 46
                )

                SettingsColumnRow {
                    SettingsColumn(title: "Server 5xx", value: report.serverErrors)
                    SettingsColumn(title: "Too large", value: report.tooLarge)
                    SettingsColumn(title: "Bad key", value: report.badKey, isLast: true)
                }
            }
        }
    }

    private var retentionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsLabel(title: "KEEP DATA FOR")

            SettingsStrip {
                ForEach(BackendRetention.allCases) { option in
                    Button {
                        retention = option
                    } label: {
                        SettingsSegmentCell(
                            title: option.title,
                            isSelected: retention == option,
                            showsDivider: option != BackendRetention.allCases.last
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .hapticFeedback(.selection, trigger: retention)

            SettingsNote(text: "Older records are deleted on the server every night.")
        }
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

    private func openConsole() {
        if let url = URL(string: "https://icloud.developer.apple.com/dashboard/") {
            openURL(url)
        }
    }
}

private enum BackendRetention: CaseIterable, Identifiable {
    case days30
    case days90
    case year
    case forever

    var id: Self { self }

    var title: String {
        switch self {
        case .days30:
            "30 days"
        case .days90:
            "90 days"
        case .year:
            "1 year"
        case .forever:
            "Forever"
        }
    }
}

private struct SettingsAddressRow: View {
    let value: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text(verbatim: value)
                .font(.weight450(size: 15, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)

            SettingsCardAction(title: "Copy", action: action)
        }
    }
}

private struct SettingsColumnRow<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 0) {
            content()
        }
        .overlay(alignment: .top) {
            Separator()
        }
    }
}

private struct SettingsColumn: View {
    let title: String
    let value: String?
    var isLast = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: title)
                .font(.weight450(size: 11))
                .foregroundStyle(Color(.systemGray))
                .lineLimit(1)

            if let value {
                Text(verbatim: value)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
            } else {
                SkeletonBar(width: 46, height: 11, delay: 0)
                    .frame(height: 18, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 9)
        .overlay(alignment: .trailing) {
            if !isLast {
                Separator(axis: .vertical)
            }
        }
    }
}

private struct SettingsButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isEnabled ? Color.accentColor : Color(.systemGray2))
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .settingsCardStyle()
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Server") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        BackendDetailView(
            provider: BackendHealthProvider(healths: .samples),
            id: [BackendHealth].samples[0].id,
            activeID: $activeID,
            report: .sample(engine: [BackendHealth].samples[0].engine)
        )
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("CloudKit") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        BackendDetailView(
            provider: BackendHealthProvider(healths: .samples),
            id: [BackendHealth].samples[1].id,
            activeID: $activeID,
            report: .sample(engine: [BackendHealth].samples[1].engine)
        )
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Loading") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        BackendDetailView(
            provider: BackendHealthProvider(healths: .samples),
            id: [BackendHealth].samples[2].id,
            activeID: $activeID,
            report: BackendReport()
        )
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Unreachable") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        BackendDetailView(
            provider: BackendHealthProvider(healths: .samples),
            id: [BackendHealth].samples[3].id,
            activeID: $activeID,
            report: .sample(engine: [BackendHealth].samples[3].engine)
        )
    }
}
