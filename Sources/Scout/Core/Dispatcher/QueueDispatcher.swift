//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

actor QueueDispatcher: Dispatcher {
    private var queue: [Block] = []
    private var isRunning = false

    func perform(_ block: @escaping Block) async throws {
        queue.append(block)

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
