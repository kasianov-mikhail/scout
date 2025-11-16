//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// Database represents the core data access surface used by the package's model layer.
/// It composes read and write capabilities over CloudKit records.
///
/// UI code should prefer the higher-level facade `AppDatabase`.
///
typealias Database = RecordWriter & RecordReader
