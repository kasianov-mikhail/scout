//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

typealias Database = DatabaseReader & DatabaseWriter

typealias DatabaseReader = RecordLocator & MetricReader & ActivityReader & Sendable
typealias DatabaseWriter = RecordWriter & Sendable
