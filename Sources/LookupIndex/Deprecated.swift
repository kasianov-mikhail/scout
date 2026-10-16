//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// The former entry point of the record-cache module.
///
/// The record cache loads automatically, so the module needs no setup.
///
@available(*, deprecated, message: "The record cache loads automatically. Remove this call.")
public enum LookupIndex {
    /// Does nothing: the record cache loads automatically.
    @available(*, deprecated, message: "The record cache loads automatically. Remove this call.")
    @MainActor public static func enable() {}
}
