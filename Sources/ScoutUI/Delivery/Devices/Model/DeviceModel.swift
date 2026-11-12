//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct DeviceModel: Equatable {
    let identifier: String

    var name: String {
        if let name = Self.marketingNames[identifier] {
            return name
        }
        if identifier.hasPrefix("MacBookPro") { return "MacBook Pro" }
        if identifier.hasPrefix("MacBookAir") { return "MacBook Air" }
        if identifier.hasPrefix("Macmini") { return "Mac mini" }
        if identifier.hasPrefix("iMac") { return "iMac" }
        if identifier.hasPrefix("MacPro") { return "Mac Pro" }
        if identifier.hasPrefix("Mac") { return "Mac" }
        return identifier
    }

    var isPad: Bool {
        identifier.hasPrefix("iPad")
    }

    var isWatch: Bool {
        identifier.hasPrefix("Watch")
    }

    var isMacBook: Bool {
        identifier.hasPrefix("MacBook")
    }

    var isDesktop: Bool {
        identifier.hasPrefix("Mac") && !isMacBook
    }

    var symbol: String {
        if isPad { return "ipad" }
        if isWatch { return "applewatch" }
        if isMacBook { return "laptopcomputer" }
        if isDesktop { return "desktopcomputer" }
        return "iphone"
    }
}
