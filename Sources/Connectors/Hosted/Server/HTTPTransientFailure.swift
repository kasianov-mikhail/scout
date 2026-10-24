//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension HTTPDatabaseError: TransientFailure {
    var isTransient: Bool {
        switch status {
        case 408, 429, 500...:
            true
        default:
            misconfiguration != nil
        }
    }

    var misconfiguration: String? {
        switch status {
        case 401:
            "the server rejected the API key"
        case 403:
            "the API key has no access to this server"
        case 404:
            "the server has no Scout API at this URL, check the base path"
        default:
            nil
        }
    }
}

extension HTTPTransportError: TransientFailure {
    var isTransient: Bool {
        error.isTransient
    }

    var misconfiguration: String? {
        error.misconfiguration
    }
}

extension URLError: TransientFailure {
    package var isTransient: Bool {
        true
    }

    package var misconfiguration: String? {
        switch code {
        case .appTransportSecurityRequiresSecureConnection:
            "App Transport Security blocks this URL, use https or add an ATS exception"
        case .badURL, .unsupportedURL:
            "the server URL is malformed or its scheme is not supported"
        case .secureConnectionFailed, .serverCertificateHasBadDate, .serverCertificateUntrusted, .serverCertificateHasUnknownRoot, .serverCertificateNotYetValid, .clientCertificateRejected, .clientCertificateRequired:
            "the TLS connection to the server is not trusted"
        default:
            nil
        }
    }
}
