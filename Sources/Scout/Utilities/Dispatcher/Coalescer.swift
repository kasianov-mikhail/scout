//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

actor Coalescer: Dispatcher {
    private var pending: Work?
    private var isRunning = false

    func perform(_ work: @escaping Work) async throws {
        pending = work

        guard !isRunning else { return }

        isRunning = true

        defer { isRunning = false }

        while let next = pending {
            pending = nil
            try await next()
        }
    }
}
