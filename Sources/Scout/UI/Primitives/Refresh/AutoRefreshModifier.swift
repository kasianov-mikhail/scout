//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AutoRefreshModifier<Token: Equatable>: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isVisible = true
    @State private var lastToken: Token?

    let token: Token
    let refreshers: [RefreshAction]

    func body(content: Content) -> some View {
        content.onAppear {
            isVisible = true
        }
        .onDisappear {
            isVisible = false
        }
        .task(id: Trigger(phase: scenePhase, isVisible: isVisible, token: token)) {
            await run()
        }
    }

    private struct Trigger: Equatable {
        let phase: ScenePhase
        let isVisible: Bool
        let token: Token
    }

    private func run() async {
        guard isVisible, scenePhase == .active, !isPreview, refreshers.count > 0 else {
            return
        }

        if token == lastToken {
            do {
                try await Task.sleep(for: .milliseconds(700))
            } catch {
                return
            }
        }

        lastToken = token

        await withTaskGroup(of: Void.self) { group in
            for refresh in refreshers {
                group.addTask { _ = await refresh() }
            }
        }

        var schedule = RefreshSchedule()
        var index = 0

        while !Task.isCancelled {
            do {
                try await Task.sleep(for: schedule.delay)
            } catch {
                break
            }
            if await refreshers[index % refreshers.count]() {
                schedule.recordSuccess()
            } else {
                schedule.recordFailure()
            }
            index += 1
        }
    }
}

private var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
