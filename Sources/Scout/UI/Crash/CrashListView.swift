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
            if let crashes = provider.crashes {
                if crashes.isEmpty {
                    Placeholder(
                        text: "No crashes",
                        systemImage: "checkmark.shield",
                        description: "No crash reports have been recorded"
                    )
                } else {
                    List {
                        ForEach(crashes, content: row)

                        if let cursor = provider.cursor {
                            PaginationFooter {
                                await provider.fetchMore(cursor: cursor, in: database)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .animation(nil, value: crashes)
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

    private func row(for crash: Crash) -> some View {
        Row {
            Text(crash.name)
                .font(.system(size: 17))
                .lineLimit(1)
                .monospaced()

            Spacer()

            if let date = crash.date {
                Text(verbatim: date.relativeString)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.gray)
            }
        } destination: {
            CrashDetailView(crash: crash)
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
