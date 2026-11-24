//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style license that can be found
// in the LICENSE file or at https://opensource.org/licenses/MIT.

import Foundation

/// Wakes the event feed when the app delivers an event, without leaving the
/// process: no CloudKit subscription, no remote notification, no timer.
///
package actor LocalEventUpdates: EventUpdatesSource {
    package static let shared = LocalEventUpdates()

    private var observers: [UUID: AsyncStream<Void>.Continuation] = [:]

    private init() {}

    package func changes() async -> AsyncStream<Void> {
        let id = UUID()
        let (stream, continuation) = AsyncStream<Void>.makeStream(bufferingPolicy: .bufferingNewest(1))
        observers[id] = continuation
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeObserver(id: id) }
        }
        return stream
    }

    package func invalidate() async {
        for observer in observers.values {
            observer.yield(())
        }
    }

    private func removeObserver(id: UUID) {
        observers[id] = nil
    }
}
