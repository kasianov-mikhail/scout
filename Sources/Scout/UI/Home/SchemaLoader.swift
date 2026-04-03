//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@MainActor
class SchemaLoader: ObservableObject {
    enum Status {
        case loading
        case ready
        case schemaError(SchemaError)
    }

    @Published var status: Status = .loading

    func verify(in container: CKContainer) async {
        if case .ready = status { return }

        do {
            status = .loading
            try await container.verifySchema()
            status = .ready
        } catch let error as SchemaError {
            status = .schemaError(error)
        } catch {
            status = .ready
        }
    }
}
