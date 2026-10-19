//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CryptoKit
import Foundation

private let maximumFrameCount = 8

package struct CrashFingerprint {
    package let value: String

    package init(name: String, reason: String?, stackTrace: [String]) {
        value = signature(name: name, reason: reason, stackTrace: stackTrace).digest
    }

    init(name: String, offsets: [String]) {
        value = ([name.normalizedText] + offsets.prefix(maximumFrameCount)).joined(separator: "\n").digest
    }
}

private func signature(name: String, reason: String?, stackTrace: [String]) -> String {
    let normalizedFrames =
        stackTrace
        .lazy
        .map(\.normalizedDetail)
        .filter { !$0.isEmpty }
        .prefix(maximumFrameCount)

    return ([name.normalizedText, (reason ?? "").normalizedDetail] + normalizedFrames)
        .joined(separator: "\n")
}

extension String {
    fileprivate var digest: String {
        SHA256.hash(data: Data(utf8)).map { String(format: "%02x", $0) }.joined()
    }

    fileprivate var normalizedDetail: String {
        normalizedText
            .replacingOccurrences(of: #"0x[0-9a-f]+"#, with: "0x", options: .regularExpression)
            .replacingOccurrences(of: #"\b\d+\b"#, with: "#", options: .regularExpression)
    }

    fileprivate var normalizedText: String {
        lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }
}
