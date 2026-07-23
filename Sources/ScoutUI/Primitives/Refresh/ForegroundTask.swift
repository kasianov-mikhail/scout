//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func foregroundTask(id token: AnyHashable = 0, _ action: @escaping @MainActor () async -> Void) -> some View {
        modifier(ForegroundTaskModifier(token: token, action: action))
    }
}

private struct ForegroundTaskModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isVisible = true

    let token: AnyHashable
    let action: @MainActor () async -> Void

    private struct Trigger: Equatable {
        let phase: ScenePhase
        let isVisible: Bool
        let token: AnyHashable
    }

    func body(content: Content) -> some View {
        content.onAppear {
            isVisible = true
        }
        .onDisappear {
            isVisible = false
        }
        .task(id: Trigger(phase: scenePhase, isVisible: isVisible, token: token)) {
            if isVisible, scenePhase == .active {
                await action()
            }
        }
    }
}
