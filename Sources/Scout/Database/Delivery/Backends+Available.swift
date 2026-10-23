//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension [Backend] {
    func available(log: FailureLog) async -> [Backend] {
        await withTaskGroup(of: Backend?.self) { group in
            for backend in self {
                group.addTask {
                    do {
                        try await backend.checkAccess?()
                        return backend
                    } catch is CancellationError {
                    } catch let error as any TransientFailure where error.isTransient {
                        backend.report(failure: error, log: log)
                    } catch let error as Backend.AccountError {
                        log.printOnce(message: "Scout can't deliver to backend \(backend.id): \(error.localizedDescription)")
                    } catch {
                        log.printOnce(message: "Failed to check access to backend \(backend.id): \(error)")
                    }
                    return nil
                }
            }

            var available: [Backend] = []

            for await case let backend? in group {
                available.append(backend)
            }

            return available
        }
    }
}
