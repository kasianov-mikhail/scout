//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

private nonisolated(unsafe) var previousExceptionHandler = NSGetUncaughtExceptionHandler()

/// Installs a handler for uncaught NSExceptions.
func installExceptionHandler() {
    NSSetUncaughtExceptionHandler { exception in
        let crash = CrashInfo(
            name: exception.name.rawValue,
            reason: exception.reason,
            stackTrace: exception.callStackSymbols
        )
        CrashArchive.system.write(crash)
        previousExceptionHandler?(exception)
    }
}
