//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct NetworkEndpoint: Identifiable {
    let name: String
    let requests: Int
    let successRate: Stability?
    let p99: TimeInterval?

    var id: String { name }

    private static let methods = ["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"]

    static func isEndpointName(_ name: String) -> Bool {
        method(in: name) != nil
    }

    static func method(in name: String) -> String? {
        guard let first = name.split(separator: " ").first.map(String.init) else {
            return nil
        }
        return methods.contains(first) ? first : nil
    }

    var method: String? {
        Self.method(in: name)
    }

    var path: String {
        guard let method else { return name }
        return String(name.dropFirst(method.count)).trimmingCharacters(in: .whitespaces)
    }

    var methodColor: Color {
        switch method {
        case "GET":
            .networkGet
        case "POST":
            .networkPost
        case "PUT", "PATCH":
            .networkPut
        case "DELETE":
            .networkDelete
        default:
            Color.fillLevel
        }
    }
}

extension NetworkEndpoint: Fixture {
    static let samples = [
        NetworkEndpoint(name: "GET /v1/projects/{id}/events", requests: 8_420, successRate: 0.998, p99: 0.21),
        NetworkEndpoint(name: "POST /v1/projects/{id}/metrics/batch", requests: 5_210, successRate: 0.991, p99: 0.62),
        NetworkEndpoint(name: "GET /v1/projects/{id}/releases/{version}", requests: 3_140, successRate: 0.972, p99: 1.9),
        NetworkEndpoint(name: "GET /v1/sessions/{id}/timeline", requests: 2_300, successRate: 0.996, p99: 0.44),
        NetworkEndpoint(name: "POST /v1/crash-reports", requests: 1_200, successRate: 0.883, p99: 4.4),
        NetworkEndpoint(name: "GET /health", requests: 640, successRate: 1.0, p99: 0.04),
        NetworkEndpoint(name: "PUT /v1/users/{id}/profile", requests: 410, successRate: 0.995, p99: 0.35),
        NetworkEndpoint(name: "DELETE /v1/sessions/{id}", requests: 120, successRate: 0.983, p99: 0.51),
    ]
}
