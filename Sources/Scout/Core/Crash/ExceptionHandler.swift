//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

private nonisolated(unsafe) var previousExceptionHandler: NSUncaughtExceptionHandler?

/// Installs a handler for uncaught NSExceptions.
func installExceptionHandler() {
    previousExceptionHandler = NSGetUncaughtExceptionHandler()
    NSSetUncaughtExceptionHandler { exception in
        let crash = CrashInfo(
            name: exception.name.rawValue,
            reason: exception.reason,
            stackTrace: exception.callStackSymbols
        )
        CrashArchive.system.write(crash)

        // Reset SIGABRT to default so the abort() that follows
        // doesn't produce a duplicate crash report.
        signal(SIGABRT, SIG_DFL)

        previousExceptionHandler?(exception)
    }
}
