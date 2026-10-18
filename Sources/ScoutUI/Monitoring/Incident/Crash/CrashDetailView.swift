//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct CrashDetailView: View {
    let crash: Crash

    @StateObject private var threads: CrashThreadsProvider
    @StateObject private var backtrace: BacktraceProvider
    @Environment(\.database) private var database

    init(crash: Crash, threads: CrashThreadsProvider? = nil, backtrace: BacktraceProvider? = nil) {
        self.crash = crash
        self._threads = StateObject(wrappedValue: threads ?? CrashThreadsProvider(crashID: crash.id))
        self._backtrace = StateObject(wrappedValue: backtrace ?? BacktraceProvider(incidentID: crash.id))
    }

    var body: some View {
        InsetList {
            VStack(alignment: .leading, spacing: 10) {
                switch (crash.source, crash.date) {
                case (.metricKit(let start?), let end?):
                    UTCTimeRangeText(start: start, end: end)
                case (_, let date?):
                    UTCTimestampText(date: date)
                case (_, nil):
                    EmptyView()
                }

                if let reason = crash.reason {
                    (Text(verbatim: "REASON:   ") + Text(reason).foregroundColor(.red))
                        .lineSpacing(4)
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical)

            ContextSection(context: crash, timelineHighlight: .red)
            StackTraceSection(crash: crash)

            if case .success(let threads) = threads.result {
                CrashThreadsSection(threads: threads)
            }
            if case .success(let loaded?) = backtrace.result {
                BinaryImagesSection(images: loaded.images)
            }
        }
        .navigationTint(.red)
        .exportToolbar(text: CrashExport(crash: crash).text)
        .monospacedNavigationTitle(en: crash.name)
        .task {
            if crash.source != .inProcess {
                await threads.fetchIfNeeded(in: database)
            }
        }
        .task {
            await backtrace.fetchIfNeeded(in: database)
        }
    }
}

#Preview {
    NavigationStack {
        CrashDetailView(crash: .sample)
    }
    .environmentObject(Tint())
}

#Preview("MetricKit") {
    NavigationStack {
        CrashDetailView(
            crash: .sample(source: .metricKit(windowStart: Date(timeIntervalSinceNow: -720))),
            threads: CrashThreadsProvider(.success(.samples), crashID: ""),
            backtrace: BacktraceProvider(.success(.sample), incidentID: "")
        )
    }
    .environmentObject(Tint())
}

#Preview("MetricKit Without Window") {
    NavigationStack {
        CrashDetailView(crash: .sample(source: .metricKit(windowStart: nil)))
    }
    .environmentObject(Tint())
}
