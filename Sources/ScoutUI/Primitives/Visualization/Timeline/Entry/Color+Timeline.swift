//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

#if os(macOS)
    import AppKit
#endif

extension Color {
    static var timelineBackground: Color {
        #if os(macOS)
            Color(nsColor: .windowBackgroundColor)
        #else
            Color(uiColor: .systemBackground)
        #endif
    }

    static let timelineLaunch = Color(red: 10 / 255, green: 108 / 255, blue: 255 / 255)
    static let timelineSession = Color(red: 18 / 255, green: 165 / 255, blue: 148 / 255)
    static let timelineSessionInk = Color(red: 10 / 255, green: 122 / 255, blue: 108 / 255)
    static let timelineMuted = Color(red: 108 / 255, green: 108 / 255, blue: 112 / 255)
    static let timelineTrack = Color(red: 229 / 255, green: 229 / 255, blue: 234 / 255)
    static let timelinePending = Color(red: 199 / 255, green: 199 / 255, blue: 204 / 255)
    static let timelineInstall = Color(red: 99 / 255, green: 99 / 255, blue: 102 / 255)
    static let timelineUnknown = Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255)
    static let timelineSeparator = Color(red: 229 / 255, green: 229 / 255, blue: 234 / 255)
    static let timelineCrash = Color(red: 215 / 255, green: 0 / 255, blue: 21 / 255)
    static let timelineCrashInk = Color(red: 196 / 255, green: 0 / 255, blue: 26 / 255)
    static let timelineHang = Color(red: 255 / 255, green: 149 / 255, blue: 0 / 255)
    static let timelineHangInk = Color(red: 179 / 255, green: 92 / 255, blue: 0 / 255)
    static let timelineResource = Color(red: 88 / 255, green: 86 / 255, blue: 214 / 255)
    static let timelineResourceInk = Color(red: 75 / 255, green: 73 / 255, blue: 194 / 255)
}
