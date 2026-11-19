//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

extension BackendDetailView {
    @ViewBuilder
    func addressColumns(for backend: BackendHealth) -> some View {
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
    func storageCard(for backend: BackendHealth) -> some View {
        SettingsCard {
            if backend.isCloud {
                HStack(spacing: 0) {
                    SettingsReadoutRow(
                        value: report.storage,
                        caption: report.storage == nil ? nil : report.storageCaption,
                        captionSkeletonWidth: report.storage == nil ? 74 : nil
                    )

                    SettingsCardAction(title: "Console") {
                        openConsole()
                    }
                }
            } else {
                SettingsReadoutRow(
                    value: report.storage,
                    caption: report.storage == nil ? nil : report.storageCaption,
                    captionSkeletonWidth: report.storage == nil ? 74 : nil
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
    func errorsSection(for backend: BackendHealth) -> some View {
        if backend.isCloud {
            SettingsLabel(title: "SEND ERRORS · 24 H")

            SettingsCard {
                SettingsReadoutRow(
                    value: report.sendErrors,
                    caption: report.sendErrors == nil ? nil : "devices could not send",
                    captionSkeletonWidth: report.sendErrors == nil ? 74 : nil,
                    skeletonWidth: 28
                )
            }

            SettingsNote(text: "Reported by devices once they reach iCloud again. CloudKit itself does not share its error rate.")
        } else {
            SettingsLabel(title: "INTAKE ERRORS · 24 H")

            SettingsCard {
                SettingsReadoutRow(
                    value: report.errorRate,
                    caption: report.errorRate == nil ? nil : report.requestCount,
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
}
