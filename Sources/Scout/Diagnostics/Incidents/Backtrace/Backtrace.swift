//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct Backtrace: Codable, Equatable, Sendable {
    let images: [Image]
    let threads: [Thread]

    struct Image: Codable, Hashable, Sendable {
        let name: String
        let uuid: UUID?
    }

    struct Thread: Codable, Equatable, Sendable {
        let attributed: Bool
        let frames: [Frame]
    }

    struct Frame: Equatable, Sendable {
        let image: Int?
        let offset: UInt64
    }
}

extension Backtrace.Frame: Codable {
    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        image = container.count == 2 ? try container.decode(Int.self) : nil
        offset = try container.decode(UInt64.self)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        if let image {
            try container.encode(image)
        }
        try container.encode(offset)
    }
}
