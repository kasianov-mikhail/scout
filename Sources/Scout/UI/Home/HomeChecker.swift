//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@MainActor
class HomeChecker: ObservableObject {
    enum State {
        case loading
        case ready
        case schemaError(SchemaError)
    }

    @Published var state: State = .loading
    @Published var iCloudWarning = false

    func verify(container: CKContainer) async {
        let status = try? await container.accountStatus()
        iCloudWarning = status != .available

        do {
            state = .loading
            try await container.verifySchema()
            state = .ready
        } catch let error as SchemaError {
            state = .schemaError(error)
        } catch {
            // Ignore other errors (network, auth, etc.)
            state = .ready
        }
    }
}
