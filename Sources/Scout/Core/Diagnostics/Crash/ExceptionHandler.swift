//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

private nonisolated(unsafe) var previousExceptionHandler: NSUncaughtExceptionHandler?
private nonisolated(unsafe) var isInstalled = false

/// Installs a handler for uncaught NSExceptions.
func installExceptionHandler() {
    // Guard against re-installation (e.g. a retried setup): a second install
    // would capture Scout's own handler as the "previous" one and recurse
    // on a real exception.
    guard !isInstalled else { return }
    isInstalled = true

    previousExceptionHandler = NSGetUncaughtExceptionHandler()
    NSSetUncaughtExceptionHandler { exception in
        let crash = CrashInfo(
            name: exception.name.rawValue,
            reason: exception.reason,
            stackTrace: exception.callStackSymbols
        )
        CrashArchive.system.write(crash)

        // Restore the pre-Scout SIGABRT handler so the abort() that follows
        // doesn't produce a duplicate crash report but still reaches any
        // previously installed third-party reporter.
        restorePreviousSignalHandler(SIGABRT)

        previousExceptionHandler?(exception)
    }
}
