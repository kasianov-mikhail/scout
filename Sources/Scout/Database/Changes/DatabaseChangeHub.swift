//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package actor DatabaseChangeHub {
    package static let shared = DatabaseChangeHub()

    private let coalescingWindow: Duration
    private let clock: any Clock<Duration>

    private var pending: [String: DatabaseChange] = [:]
    private var emission: Task<Void, Never>?
    private var subscribers: [UUID: AsyncStream<DatabaseChange>.Continuation] = [:]

    package init(coalescingWindow: Duration = .seconds(2), clock: any Clock<Duration> = ContinuousClock()) {
        self.coalescingWindow = coalescingWindow
        self.clock = clock
    }

    package var subscriberCount: Int {
        subscribers.count
    }

    package var pendingCount: Int {
        pending.count
    }

    package func publish(_ change: DatabaseChange) {
        guard !subscribers.isEmpty else {
            return
        }

        pending[change.backendID] = pending[change.backendID].map { $0.merged(with: change) } ?? change

        guard emission == nil else {
            return
        }

        emission = Task { [clock, coalescingWindow] in
            do {
                try await clock.sleep(for: coalescingWindow)
            } catch {
                return
            }
            await self.emit()
        }
    }

    package func stream() -> AsyncStream<DatabaseChange> {
        let id = UUID()

        var continuation: AsyncStream<DatabaseChange>.Continuation?
        let stream = AsyncStream<DatabaseChange> { continuation = $0 }

        if let continuation {
            subscribers[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task {
                    await self?.remove(id)
                }
            }
        }

        return stream
    }

    package func flush() {
        emission?.cancel()
        emission = nil
        emit()
    }

    private func emit() {
        emission = nil

        let changes = pending.values.sorted { $0.at < $1.at }
        pending.removeAll()

        guard !subscribers.isEmpty else {
            return
        }

        for change in changes {
            for continuation in subscribers.values {
                continuation.yield(change)
            }
        }
    }

    private func remove(_ id: UUID) {
        subscribers[id] = nil
    }
}
