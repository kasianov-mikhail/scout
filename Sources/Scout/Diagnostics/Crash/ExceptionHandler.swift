//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

private nonisolated(unsafe) var previousExceptionHandler: NSUncaughtExceptionHandler?
private nonisolated(unsafe) var isInstalled = false
private nonisolated(unsafe) var identity: Identity?

func installExceptionHandler(identity: Identity) {
    guard !isInstalled else { return }
    isInstalled = true

    Scout.identity = identity

    previousExceptionHandler = NSGetUncaughtExceptionHandler()
    NSSetUncaughtExceptionHandler { exception in
        if let identity = Scout.identity {
            let crash = CrashInfo(
                name: exception.name.rawValue,
                reason: exception.reason,
                stackTrace: exception.callStackSymbols,
                identity: identity
            )
            CrashArchive.system.write(crash)
        }

        restorePreviousSignalHandler(SIGABRT)
        previousExceptionHandler?(exception)
    }
}
