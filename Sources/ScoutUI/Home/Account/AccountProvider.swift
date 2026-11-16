//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

@MainActor
final class AccountProvider: ObservableObject {
    @Published private(set) var issue: Backend.AccountError?
    @Published private(set) var isResolved = false

    func probe(_ backend: Backend) async {
        guard let check = backend.checkAccess else {
            resolve(nil)
            return
        }
        do {
            try await check()
            resolve(nil)
        } catch is CancellationError {
            return
        } catch {
            let error = Backend.AccountError(error)
            resolve(error.blocksAccess ? error : nil)
        }
    }

    private func resolve(_ error: Backend.AccountError?) {
        issue = error
        isResolved = true
    }
}
