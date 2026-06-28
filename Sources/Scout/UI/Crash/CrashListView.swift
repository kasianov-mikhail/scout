//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct CrashListView: View {
    @Environment(\.database) var database
    @StateObject private var provider = CrashProvider()

    var body: some View {
        Group {
            if let groups = provider.groups {
                if groups.isEmpty {
                    Placeholder(
                        text: "No crashes",
                        systemImage: "checkmark.shield",
                        description: "No crash reports have been recorded"
                    )
                } else {
                    List {
                        ForEach(groups, content: row)

                        if let cursor = provider.cursor {
                            PaginationFooter {
                                await provider.fetchMore(cursor: cursor, in: database)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .animation(nil, value: groups)
                }
            } else {
                ProgressView().frame(maxHeight: .infinity)
            }
        }
        .navigationTitle(en: "Crashes")
        .task {
            await provider.fetch(in: database)
        }
    }

    private func row(for group: CrashGroup) -> some View {
        Row {
            VStack(alignment: .leading, spacing: 5) {
                Text(group.name)
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(1)
                    .monospaced()

                if let reason = group.reason {
                    Text(reason)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.gray)
                        .lineLimit(1)
                }

                Text(verbatim: "\(group.affectedSessions) sessions")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text(verbatim: "\(group.count)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.red)

                if let date = group.lastDate {
                    Text(verbatim: date.relativeString)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.gray)
                }
            }
        } destination: {
            CrashGroupDetailView(group: group)
        }
    }
}

#Preview {
    NavigationStack {
        CrashListView()
    }
}

#Preview("Empty State") {
    NavigationStack {
        Placeholder(
            text: "No crashes",
            systemImage: "checkmark.shield",
            description: "No crash reports have been recorded"
        )
        .navigationTitle(en: "Crashes")
    }
}
