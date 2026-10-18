//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Runtime {
    /// Records that a screen became visible.
    ///
    /// Call it when the screen appears, and call ``ScreenVisit/end()`` on the result
    /// when the screen disappears. The latest visible screen is the current one: it
    /// gets a `Screen` record with its start and end, linked to the session. Scout
    /// closes the current screen when the app goes to the background and opens it
    /// again when the app returns.
    ///
    /// ```swift
    /// override func viewDidAppear(_ animated: Bool) {
    ///     super.viewDidAppear(animated)
    ///     visit = scout.openScreen(name: "Feed")
    /// }
    ///
    /// override func viewDidDisappear(_ animated: Bool) {
    ///     super.viewDidDisappear(animated)
    ///     visit?.end()
    /// }
    /// ```
    ///
    /// In SwiftUI, use ``SwiftUI/View/scoutScreen(name:)`` instead.
    ///
    /// - Parameter name: The screen name that groups its views in the dashboard.
    /// - Returns: The visit to end when the screen disappears.
    ///
    public func openScreen(name: String) -> ScreenVisit {
        let visit = ScreenVisit(id: UUID(), runtime: self)
        record { $0.show(visitID: visit.id, name: name) }
        return visit
    }

    func record(transition: (inout ScreenStack) -> [ScreenChange]) {
        guard !backends.isEmpty else { return }

        let date = Date()
        let identity = identity.snapshot
        let backends = backends
        let dispatcher = dispatcher

        screens.mutate { tracker in
            let commands = transition(&tracker.stack).map { $0.command(identity: identity, date: date) }

            guard !commands.isEmpty else { return }

            let previous = tracker.pending
            tracker.pending = Task {
                await previous?.value
                do {
                    try await persistentContainer.run(commands)
                    try await backends.synchronize(using: dispatcher)
                } catch {
                    print("Failed to save screen: \(error)")
                }
            }
        }
    }
}

/// A visible screen that ``Runtime/openScreen(name:)`` recorded.
public struct ScreenVisit: Sendable {
    let id: UUID
    let runtime: Runtime

    /// Records that the screen is no longer visible.
    public func end() {
        runtime.record { $0.hide(visitID: id) }
    }
}

struct ScreenTracker: Sendable {
    var stack = ScreenStack()
    var pending: Task<Void, Never>?
}

extension ScreenChange {
    fileprivate func command(identity: Identity.Snapshot, date: Date) -> any Command {
        switch self {
        case .open(let screenID, let name, let previous):
            ScreenEntry.Trigger(screenID: screenID, name: name, previous: previous, identity: identity, date: date)
        case .close(let screenID):
            ScreenEntry.Complete(screenID: screenID, date: date)
        }
    }
}
