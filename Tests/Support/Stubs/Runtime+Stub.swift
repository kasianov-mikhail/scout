//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

extension Runtime {
    static let stub = Runtime(backends: [makeBackend(id: "stub")], identity: .stub, dispatcher: IdleDispatcher())
}

private struct IdleDispatcher: Dispatcher {
    func perform(_ work: @escaping Work) async throws {}
}
