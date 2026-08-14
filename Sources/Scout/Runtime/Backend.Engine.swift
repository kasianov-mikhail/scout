//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension Backend {
    package enum Engine: Sendable {
        case cloudKit
        case server(ServerInfo)
        case local

        package struct ServerInfo: Sendable {
            package let endpoint: String
            package let hasAPIKey: Bool
            package let isSecure: Bool

            package init(endpoint: String, hasAPIKey: Bool, isSecure: Bool) {
                self.endpoint = endpoint
                self.hasAPIKey = hasAPIKey
                self.isSecure = isSecure
            }

            package var setupWarning: String? {
                guard hasAPIKey, !isSecure else {
                    return nil
                }
                return """
                    [Scout] The API key for '\(endpoint)' will be sent over a non-HTTPS connection in cleartext. \
                    Use an https:// URL.
                    """
            }
        }
    }
}
