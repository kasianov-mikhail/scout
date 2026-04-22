//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

actor QueueDispatcher: Dispatcher {
    private var queue: [Work] = []
    private var isRunning = false

    func perform(_ work: @escaping Work) async throws {
        queue.append(work)

        guard !isRunning else { return }

        isRunning = true

        defer { isRunning = false }

        while let next = queue.first {
            queue.removeFirst()

            do {
                try await next()
            } catch {
                queue.removeAll()
                throw error
            }
        }
    }
}
