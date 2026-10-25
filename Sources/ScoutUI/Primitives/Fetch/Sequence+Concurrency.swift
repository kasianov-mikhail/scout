//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension Sequence {
    @MainActor
    func concurrentForEach(_ operation: @escaping @MainActor (Element) async -> Void) async {
        _ = await concurrentMap(operation)
    }

    @MainActor
    func concurrentMap<T: Sendable>(_ transform: @escaping @MainActor (Element) async -> T) async -> [T] {
        let actions: [@MainActor () async -> T] = map { element in
            { await transform(element) }
        }

        return await withTaskGroup(of: T.self) { group in
            for action in actions {
                group.addTask {
                    await action()
                }
            }

            var results: [T] = []
            for await result in group {
                results.append(result)
            }
            return results
        }
    }
}
