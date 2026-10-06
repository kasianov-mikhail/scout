//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension [Backend] {
    var available: [Backend] {
        get async {
            await withTaskGroup(of: Backend?.self) { group in
                for backend in self {
                    group.addTask {
                        do {
                            try await backend.verifyAccess?()
                            return backend
                        } catch {
                            return nil
                        }
                    }
                }

                var available: [Backend] = []

                for await backend in group {
                    if let backend {
                        available.append(backend)
                    }
                }

                return available
            }
        }
    }
}
