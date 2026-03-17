//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct CrashDetailView: View {
    let crash: Crash

    @EnvironmentObject var tint: Tint

    var body: some View {
        List {
            headerSection

//            if let reason = crash.reason {
//                reasonSection(reason)
//            }

            if !crash.stackTrace.isEmpty {
                stackTraceSection
            }
        }
        .onAppear {
            tint.value = .red
        }
        .onDisappear {
            tint.value = nil
        }
        .listStyle(.plain)
        .toolbarBackground(Color.red.opacity(0.12), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationTitle(crash.name)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let date = crash.date {
                Text(utcDateFormatter.string(from: date) + " UTC")
                    .font(.system(size: 16))
                    .monospaced()
            }

            if let reason = crash.reason {
                Text("REASON:   ").fontWeight(.bold)
                + Text(reason).fontWeight(.bold).foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var stackTraceSection: some View {
        Header(title: "Stack Trace")

        ForEach(Array(crash.stackTrace.enumerated()), id: \.offset) { _, frame in
            Text(frame)
                .font(.system(size: 12))
                .monospaced()
                .lineLimit(2)
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        CrashDetailView(crash: .sample)
    }
    .environmentObject(Tint())
}
