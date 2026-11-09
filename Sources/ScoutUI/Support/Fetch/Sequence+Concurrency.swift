//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension Sequence {
    @MainActor
    func concurrentForEach(_ operation: @escaping @MainActor (Element) async -> Void) async {
        let actions: [@MainActor () async -> Void] = map { element in
            { await operation(element) }
        }

        await withTaskGroup(of: Void.self) { group in
            for action in actions {
                group.addTask {
                    await action()
                }
            }
        }
    }
}
