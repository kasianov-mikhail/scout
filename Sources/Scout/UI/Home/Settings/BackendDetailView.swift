//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct BackendDetailView: View {
    @ObservedObject var provider: BackendHealthProvider
    let id: String
    @Binding var activeID: String

    @State private var isChecking = false
    @State private var message: Message?

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
        .message($message)
    }

    private func content(for backend: BackendHealth) -> some View {
        List {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: backend.status.healthIcon)
                        .font(.title2)
                        .foregroundStyle(backend.status.healthColor)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(verbatim: backend.status.healthLabel)
                            .font(.headline)
                        Text(verbatim: backend.engine.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(verbatim: backend.endpoint)
                    .codeChipStyle()
            }
            .padding(.vertical, 6)
            .listRowSeparator(.hidden)

            Header(title: "Health")

            DetailValueRow(title: "Latency", value: backend.latencyLabel)

            if let spread = backend.pingSpreadLabel {
                DetailValueRow(title: "Min / Avg / Max", value: spread)
            }

            DetailValueRow(title: "Last Checked", value: backend.lastCheckedLabel)

            if backend.pings.count > 0 {
                HStack {
                    Text(verbatim: "Recent Pings")
                    Spacer()
                    PingSparkline(pings: backend.pings)
                        .frame(width: 144, height: 28)
                }
            }

            if backend.engine == .server {
                Header(title: "Connection")

                DetailValueRow(title: "API Key", value: backend.hasAPIKey ? "Configured" : "Not set")
                DetailValueRow(title: "Timeout", value: "10 s")
                DetailValueRow(title: "Transport", value: backend.isSecure ? "HTTPS" : "HTTP")
            }

            Header(title: "Actions")

            if backend.id != activeID {
                Button {
                    activeID = backend.id
                } label: {
                    Text(verbatim: "Use This Backend")
                        .foregroundStyle(.tint)
                }
            }

            Button {
                isChecking = true
                Task {
                    await provider.refresh(id: backend.id)
                    isChecking = false
                }
            } label: {
                HStack {
                    Text(verbatim: "Check Now")
                        .foregroundStyle(.tint)
                    if isChecking {
                        Spacer()
                        RingIndicator(size: 22)
                    }
                }
            }
            .disabled(isChecking)

            if let benchmark = backend.runBenchmark {
                BenchmarkButton(benchmark: benchmark, message: $message)

                Text(
                    verbatim:
                        "The benchmark issues test queries to verify the \(RequestLimiter.requestLimit)-request limit."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}

struct DetailValueRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(verbatim: title)
            Spacer()
            Text(verbatim: value)
                .font(.body.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

struct PingSparkline: View {
    let pings: [Int]

    private static let spacing: CGFloat = 3

    var body: some View {
        GeometryReader { proxy in
            let peak = Double(pings.max() ?? 1)
            let slots = CGFloat(BackendHealth.maxPingHistory)
            let barWidth = (proxy.size.width - Self.spacing * (slots - 1)) / slots

            HStack(alignment: .bottom, spacing: Self.spacing) {
                Spacer(minLength: 0)

                ForEach(Array(pings.enumerated()), id: \.offset) { _, ping in
                    Capsule()
                        .fill(.tint.opacity(0.6))
                        .frame(width: barWidth, height: max(3, proxy.size.height * Double(ping) / peak))
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Server") {
    @Previewable @State var activeID = [BackendHealth].samples[0].id
    NavigationStack {
        BackendDetailView(
            provider: BackendHealthProvider(healths: .samples),
            id: [BackendHealth].samples[0].id,
            activeID: $activeID
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
            activeID: $activeID
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
            activeID: $activeID
        )
    }
}
