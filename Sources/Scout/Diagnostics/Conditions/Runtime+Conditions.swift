//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import os

private nonisolated(unsafe) var isInstalled = false
private nonisolated(unsafe) var memorySource: (any DispatchSourceMemoryPressure)?

extension Runtime {
    func installConditionMonitor() {
        guard !isInstalled else { return }
        isInstalled = true

        let source = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical], queue: .global(qos: .utility))
        source.setEventHandler {
            let event = memorySource?.data ?? []
            record(condition: event.contains(.critical) ? .memoryCritical : .memoryWarning)
        }
        memorySource = source
        source.resume()

        NotificationCenter.default.addObserver(forName: ProcessInfo.thermalStateDidChangeNotification, object: nil, queue: nil) { _ in
            record(condition: Condition(thermalState: ProcessInfo.processInfo.thermalState))
        }
        NotificationCenter.default.addObserver(forName: .NSProcessInfoPowerStateDidChange, object: nil, queue: nil) { _ in
            record(condition: Condition(lowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled))
        }
    }

    func recordCurrentConditions() {
        let date = Date()
        let current = [
            Condition(thermalState: ProcessInfo.processInfo.thermalState),
            Condition(lowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled),
        ]

        var started: [Condition] = []
        conditions.mutate { started = $0.start(current: current) }

        for condition in started {
            save(condition: condition, date: date)
        }
    }

    private func record(condition: Condition) {
        let date = Date()

        var admitted = false
        conditions.mutate { admitted = $0.admits(condition: condition, date: date) }

        if admitted {
            save(condition: condition, date: date)
        }
    }

    private func save(condition: Condition, date: Date) {
        guard !backends.isEmpty else { return }

        let command = ConditionEntry.Trigger(
            condition: condition,
            value: condition.group == .memory ? availableMemory : 0,
            identity: identity.snapshot,
            date: date
        )
        let backends = backends
        let dispatcher = dispatcher

        Task {
            do {
                try await persistentContainer.run(command)
                try await backends.synchronize(using: dispatcher)
            } catch {
                print("Failed to save condition: \(error)")
            }
        }
    }
}

private var availableMemory: Double {
    #if os(iOS)
        Double(os_proc_available_memory())
    #else
        0
    #endif
}
