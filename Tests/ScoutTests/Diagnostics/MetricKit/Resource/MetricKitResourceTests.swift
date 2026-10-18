//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("MetricKitResource")
struct MetricKitResourceTests {
    private let window = DateInterval(start: Date(timeIntervalSince1970: 1_750_000_000), duration: 86_400)

    @Test("A CPU exception gives its CPU time against the sampled time")
    func cpuReason() {
        let resource = makeResource(kind: .cpu, amount: 92.4, sampledSeconds: 180)

        #expect(resource.name == "CPU Exception")
        #expect(resource.reason == "92 s of CPU time in 180 s")
        #expect(makeResource(kind: .cpu, amount: 92.4).reason == "92 s of CPU time")
    }

    @Test("A disk write exception gives the megabytes written")
    func diskWriteReason() {
        let resource = makeResource(kind: .diskWrite, amount: 1_073_741_824)

        #expect(resource.name == "Disk Write Exception")
        #expect(resource.reason == "1024 MB written to disk")
    }

    @Test("The stack and the window come from MetricKit")
    func stackAndWindow() {
        let resource = makeResource(kind: .cpu, amount: 90)

        #expect(resource.stackTrace.count == 2)
        #expect(resource.date == window.end)
        #expect(resource.source == .metricKit(windowStart: window.start))
    }

    @Test("Exceptions of one kind and stack share a fingerprint whatever the amount")
    func fingerprintIgnoresAmount() {
        #expect(makeResource(kind: .cpu, amount: 90).fingerprint == makeResource(kind: .cpu, amount: 120).fingerprint)
        #expect(makeResource(kind: .cpu, amount: 90).fingerprint != makeResource(kind: .diskWrite, amount: 90).fingerprint)
    }

    @Test("The id is stable and differs by kind, amount, and window")
    func idSeparatesReports() {
        let base = makeResource(kind: .cpu, amount: 90)
        let later = DateInterval(start: window.end, duration: 86_400)
        let others = [
            makeResource(kind: .diskWrite, amount: 90).id,
            makeResource(kind: .cpu, amount: 91).id,
            makeResource(kind: .cpu, amount: 90, window: later).id,
        ]

        #expect(base.id == makeResource(kind: .cpu, amount: 90).id)
        #expect(Set(others + [base.id]).count == 4)
    }

    private func makeResource(kind: ResourceKind, amount: Double, sampledSeconds: Double? = nil, window: DateInterval? = nil) -> MetricKitResource {
        MetricKitResource(
            kind: kind,
            amount: amount,
            sampledSeconds: sampledSeconds,
            appVersion: "3.2.0",
            processID: 412,
            window: window ?? self.window,
            frames: [
                MetricKitStackTree.Frame(binaryName: "MyApp", binaryUUID: nil, offsetIntoBinaryTextSegment: 4096, address: nil, sampleCount: 9, subFrames: []),
                MetricKitStackTree.Frame(binaryName: "UIKitCore", binaryUUID: nil, offsetIntoBinaryTextSegment: 512, address: nil, sampleCount: 9, subFrames: []),
            ]
        )
    }
}
