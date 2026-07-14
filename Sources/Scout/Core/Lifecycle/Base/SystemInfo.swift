//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum SystemInfo {
    static var deviceModel: String {
        if let simulator = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulator
        }
        var info = utsname()
        uname(&info)
        return Mirror(reflecting: info.machine).children.reduce(into: "") { identifier, element in
            guard let scalar = element.value as? Int8, scalar != 0 else { return }
            identifier.append(Character(UnicodeScalar(UInt8(scalar))))
        }
    }

    static var osVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(osName) \(version.majorVersion).\(version.minorVersion)"
    }

    static var locale: String {
        Locale.current.identifier
    }

    enum Channel: String {
        case debug = "Debug"
        case simulator = "Simulator"
        case testFlight = "TestFlight"
        case appStore = "App Store"
    }

    static var buildChannel: Channel {
        #if DEBUG
            .debug
        #elseif targetEnvironment(simulator)
            .simulator
        #else
            Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" ? .testFlight : .appStore
        #endif
    }

    static var channel: String {
        buildChannel.rawValue
    }

    static var isInternalBuild: Bool {
        buildChannel != .appStore
    }

    private static var osName: String {
        #if os(iOS)
            "iOS"
        #elseif os(macOS)
            "macOS"
        #elseif os(tvOS)
            "tvOS"
        #elseif os(watchOS)
            "watchOS"
        #elseif os(visionOS)
            "visionOS"
        #else
            "Unknown"
        #endif
    }
}
