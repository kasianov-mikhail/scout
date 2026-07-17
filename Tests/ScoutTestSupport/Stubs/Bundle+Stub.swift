//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Bundle {
    static func stub(appVersion: String? = nil, buildNumber: String? = nil) -> Bundle {
        var info: [String: Any] = [:]
        appVersion.map { info["CFBundleShortVersionString"] = $0 }
        buildNumber.map { info["CFBundleVersion"] = $0 }
        return StubBundle(info: info)
    }
}

private final class StubBundle: Bundle, @unchecked Sendable {
    private let info: [String: Any]

    init(info: [String: Any]) {
        self.info = info

        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
        super.init(path: path.path)!
    }

    override var infoDictionary: [String: Any]? { info }
}
