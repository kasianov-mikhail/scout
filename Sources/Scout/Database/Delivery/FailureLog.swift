//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

final class FailureLog: Sendable {
    static let console = FailureLog { print($0) }

    private let printed = Protected<Set<String>>([])
    private let write: @Sendable (String) -> Void

    init(write: @escaping @Sendable (String) -> Void) {
        self.write = write
    }

    func printOnce(message: String) {
        var isNew = false
        printed.mutate { isNew = $0.insert(message).inserted }

        if isNew {
            write(message)
        }
    }
}
