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
                    Placeholder(text: "No crashes").frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(crashes, content: row)

                        if let cursor = provider.cursor {
                            ProgressView()
                                .task {
                                    await provider.fetchMore(cursor: cursor, in: database)
                                }
                                .id(UUID())
                                .frame(height: 72)
                                .frame(maxWidth: .infinity)
                                .listRowSeparator(.hidden, edges: .bottom)
                        }
                    }
                    .listStyle(.plain)
                    .animation(nil, value: UUID())
                }
            } else {
                ProgressView().frame(maxHeight: .infinity)
            }
        }
        .navigationTitle("Crashes")
        .task {
            await provider.fetch(in: database)
        }
    }

    private func row(for crash: Crash) -> some View {
        ZStack {
            HStack(spacing: 12) {
                Text(crash.name)
                    .font(.system(size: 17))
                    .lineLimit(1)
                    .monospaced()

                Spacer()

                if let date = crash.date {
                    Text(date, style: .relative)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.gray)
                }
            }

            NavigationLink {
                CrashDetailView(crash: crash)
            } label: {
                EmptyView()
            }
            .opacity(0)
        }
        .alignmentGuide(.listRowSeparatorTrailing) { dimension in
            dimension[.trailing]
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        CrashListView()
    }
}
