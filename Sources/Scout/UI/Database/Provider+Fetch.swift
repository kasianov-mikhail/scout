//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Provider {
    func fetchAgain(in database: DatabaseReader) async {
        result = nil
        await resolve(in: database)
    }

    func fetchIfNeeded(in database: DatabaseReader) async {
        guard result == nil else {
            return
        }
        await resolve(in: database)
    }

    func fetchIfFailed(in database: DatabaseReader) async {
        guard error != nil else {
            return
        }
        await fetchAgain(in: database)
    }

    private func resolve(in database: DatabaseReader) async {
        do {
            result = .success(try await fetch(in: database))
        } catch is CancellationError {
            // A cancelled task (e.g. the view was recreated) leaves the result untouched so it retries.
        } catch {
            result = .failure(error)
        }
    }
}
