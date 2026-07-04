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

    private static func method(in name: String) -> String? {
        guard let first = name.split(separator: " ").first.map(String.init) else { return nil }
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
        case "GET": .green
        case "POST": .blue
        case "PUT", "PATCH": .orange
        case "DELETE": .red
        default: .gray
        }
    }
}

extension NetworkEndpoint {
    static let samples = [
        NetworkEndpoint(name: "GET /v1/events", requests: 8_420, successRate: 0.998, p99: 0.21),
        NetworkEndpoint(name: "POST /v1/metrics", requests: 5_210, successRate: 0.991, p99: 0.62),
        NetworkEndpoint(name: "GET /v1/releases", requests: 3_140, successRate: 0.972, p99: 1.9),
        NetworkEndpoint(name: "POST /v1/crash", requests: 1_180, successRate: 0.883, p99: 4.4),
        NetworkEndpoint(name: "GET /health", requests: 640, successRate: 1.0, p99: 0.04),
    ]
}
