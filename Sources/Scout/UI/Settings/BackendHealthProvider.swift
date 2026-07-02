//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

@MainActor
class BackendHealthProvider: ObservableObject {
    @Published private(set) var backends: [BackendHealth]

    init(backends: [Backend]) {
        self.backends = backends.map(BackendHealth.init)
    }

    init(healths: [BackendHealth]) {
        self.backends = healths
    }

    func refreshAll() async {
        await withTaskGroup(of: ProbeResult.self) { group in
            for health in backends {
                let id = health.id
                let probe = health.probe
                group.addTask {
                    await Self.measure(id: id, probe: probe)
                }
            }
            for await result in group {
                apply(result)
            }
        }
    }

    func refresh(id: String) async {
        guard let probe = backends.first(where: { $0.id == id })?.probe else { return }
        apply(await Self.measure(id: id, probe: probe))
    }

    private struct ProbeResult: Sendable {
        let id: String
        let status: Backend.Status
        let latency: Int?
    }

    private static func measure(id: String, probe: @Sendable () async -> Backend.Status) async -> ProbeResult {
        let clock = ContinuousClock()
        let start = clock.now
        let status = await probe()
        let elapsed = start.duration(to: clock.now)
        return ProbeResult(id: id, status: status, latency: status == .reachable ? elapsed.milliseconds : nil)
    }

    private func apply(_ result: ProbeResult) {
        guard let index = backends.firstIndex(where: { $0.id == result.id }) else { return }
        backends[index] = backends[index].recording(status: result.status, latency: result.latency, at: Date())
    }
}

extension Duration {
    var milliseconds: Int {
        Int(components.seconds) * 1_000 + Int(components.attoseconds / 1_000_000_000_000_000)
    }
}

extension BackendHealthProvider {
    static func fixture() -> BackendHealthProvider {
        BackendHealthProvider(healths: BackendHealth.samples)
    }
}
