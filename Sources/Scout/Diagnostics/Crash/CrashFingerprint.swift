//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CryptoKit
import Foundation

package struct CrashFingerprint {
    private static let maximumFrameCount = 8

    package let value: String

    package init(name: String, reason: String?, stackTrace: [String]) {
        let signature = Self.signature(name: name, reason: reason, stackTrace: stackTrace)
        value = SHA256.hash(data: Data(signature.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

extension CrashFingerprint {
    fileprivate static func signature(name: String, reason: String?, stackTrace: [String]) -> String {
        let normalizedFrames =
            stackTrace
            .lazy
            .map(normalizeFrame)
            .filter { !$0.isEmpty }
            .prefix(maximumFrameCount)

        return ([normalizeText(name), normalizeText(reason ?? "")] + normalizedFrames)
            .joined(separator: "\n")
    }

    fileprivate static func normalizeFrame(_ frame: String) -> String {
        normalizeText(frame)
            .replacingOccurrences(of: #"0x[0-9a-f]+"#, with: "0x", options: .regularExpression)
            .replacingOccurrences(of: #"\b\d+\b"#, with: "#", options: .regularExpression)
    }

    fileprivate static func normalizeText(_ text: String) -> String {
        text
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }
}
