//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

/// AppDatabase defines the read-only database surface used by the UI.
/// It abstracts record lookup and query operations for use in SwiftUI
/// and is intended for dependency injection via the environment.
///
typealias AppDatabase = RecordLookup & RecordReader & Sendable

extension EnvironmentValues {
    @Entry var database: AppDatabase = DefaultDatabase()
}
