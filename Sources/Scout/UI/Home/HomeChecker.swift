//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@MainActor
class HomeChecker: ObservableObject {
    @Published var schemaError: SchemaError?
    @Published var iCloudWarning = false

    func verify(container: CKContainer) async {
        let status = (try? await container.accountStatus()) ?? .couldNotDetermine
        iCloudWarning = status != .available

        do {
            try await container.verifySchema()
            schemaError = nil
        } catch let error as SchemaError {
            schemaError = error
        } catch {
            // Ignore other errors (network, auth, etc.)
        }
    }
}
