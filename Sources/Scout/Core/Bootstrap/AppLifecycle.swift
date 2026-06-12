//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

/// Cross-platform application lifecycle notification names.
enum AppLifecycle {
    /// `willEnterForeground` on iOS, `willBecomeActive` on macOS.
    static var willEnterForeground: Notification.Name {
        #if canImport(UIKit)
            UIApplication.willEnterForegroundNotification
        #else
            NSApplication.willBecomeActiveNotification
        #endif
    }

    /// `didEnterBackground` on iOS, `didResignActive` on macOS.
    static var didEnterBackground: Notification.Name {
        #if canImport(UIKit)
            UIApplication.didEnterBackgroundNotification
        #else
            NSApplication.didResignActiveNotification
        #endif
    }
}
