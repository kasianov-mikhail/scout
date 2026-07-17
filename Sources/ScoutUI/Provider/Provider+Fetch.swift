//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

extension Provider {
    func fetchAgain(in database: DatabaseReader) async {
        do {
            result = .success(try await fetch(in: database))
        } catch is CancellationError {
            // A cancelled task (e.g. the view was recreated) leaves the result untouched so it retries.
        } catch {
            result = .failure(error)
        }
    }

    func fetchIfNeeded(in database: DatabaseReader) async {
        guard result == nil else {
            return
        }
        await fetchAgain(in: database)
    }

    func fetchIfFailed(in database: DatabaseReader) async {
        guard error != nil else {
            return
        }
        await fetchAgain(in: database)
    }

    @discardableResult
    func fetchLatest(in database: DatabaseReader) async -> Bool {
        do {
            result = .success(try await fetch(in: database))
            return true
        } catch is CancellationError {
            return true
        } catch {
            if result == nil {
                result = .failure(error)
            }
            return false
        }
    }
}
