//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

actor SerialExecutor {
    typealias Action = () async throws -> Void

    enum State { case idle, running, pending }

    private let action: Action
    private var state: State = .idle

    init(action: @escaping Action) {
        self.action = action
    }

    func run() async throws {
        switch state {
        case .idle:
            try await runCycle()
        case .running:
            state = .pending
        case .pending:
            break
        }
    }

    private func runCycle() async throws {
        state = .running

        defer { state = .idle }

        try await action()

        if state == .pending {
            try await runCycle()
        }
    }
}
