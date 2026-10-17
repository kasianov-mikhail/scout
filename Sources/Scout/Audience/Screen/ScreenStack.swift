//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct ScreenStack {
    private var visible: [VisibleScreen] = []
    private var current: OpenScreen?
    private var previous: String?
    private var isSuspended = false

    mutating func show(visitID: UUID, name: String) -> [ScreenChange] {
        visible.removeAll { $0.visitID == visitID }
        visible.append(VisibleScreen(visitID: visitID, name: name))
        return refresh()
    }

    mutating func hide(visitID: UUID) -> [ScreenChange] {
        visible.removeAll { $0.visitID == visitID }
        return refresh()
    }

    mutating func suspend() -> [ScreenChange] {
        isSuspended = true
        let changes = refresh()
        previous = nil
        return changes
    }

    mutating func resume() -> [ScreenChange] {
        isSuspended = false
        return refresh()
    }

    private mutating func refresh() -> [ScreenChange] {
        let top = isSuspended ? nil : visible.last

        guard top?.visitID != current?.visitID else {
            return []
        }

        var changes: [ScreenChange] = []

        if let current {
            changes.append(.close(screenID: current.screenID))
            previous = current.name
        }

        current = top.map(OpenScreen.init)

        if let current {
            changes.append(.open(screenID: current.screenID, name: current.name, previous: previous))
        }

        return changes
    }
}

enum ScreenChange: Equatable {
    case open(screenID: UUID, name: String, previous: String?)
    case close(screenID: UUID)
}

private struct VisibleScreen {
    let visitID: UUID
    let name: String
}

private struct OpenScreen {
    let screenID: UUID
    let visitID: UUID
    let name: String

    init(screen: VisibleScreen) {
        screenID = UUID()
        visitID = screen.visitID
        name = screen.name
    }
}
