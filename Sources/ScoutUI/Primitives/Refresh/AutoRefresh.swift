//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

typealias RefreshAction = @MainActor () async -> Bool

extension View {
    func autoRefresh(_ refresh: @escaping RefreshAction) -> some View {
        modifier(AutoRefreshModifier(token: 0, refreshers: [refresh]))
    }

    func autoRefresh(on token: some Equatable, _ refresh: @escaping RefreshAction) -> some View {
        modifier(AutoRefreshModifier(token: token, refreshers: [refresh]))
    }

    func autoRefresh(rotating refreshers: [RefreshAction]) -> some View {
        modifier(AutoRefreshModifier(token: 0, refreshers: refreshers))
    }
}

private struct AutoRefreshModifier<Token: Equatable>: ViewModifier {
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

        while !Task.isCancelled {
            do {
                try await Task.sleep(for: schedule.delay)
            } catch {
                break
            }

            var isSuccess = true
            for refresh in refreshers {
                guard !Task.isCancelled else { return }
                if await refresh() == false {
                    isSuccess = false
                }
            }

            if isSuccess {
                schedule.recordSuccess()
            } else {
                schedule.recordFailure()
            }
        }
    }
}

private var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
