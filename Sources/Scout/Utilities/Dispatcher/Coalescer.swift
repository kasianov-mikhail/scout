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

        var caught: Error?

        while let next = pending {
            pending = nil
            do {
                try await next()
            } catch {
                if caught == nil { caught = error }
            }
        }

        if let caught {
            throw caught
        }
    }
}
