//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

/// A minimal backend identified only by `id`, for tests that exercise backend-set membership (e.g. `cleanup`) without driving real delivery.
func makeBackend(id: String) -> Backend {
    Backend(
        id: id,
        database: InMemoryDatabase(),
        checkAvailability: { true },
        displayName: id,
        displayHost: id
    )
}
