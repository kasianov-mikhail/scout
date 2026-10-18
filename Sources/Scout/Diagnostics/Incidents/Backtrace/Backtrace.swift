//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

package struct Backtrace: Codable, Equatable, Sendable {
    package let images: [Image]
    package let threads: [Thread]

    package init(images: [Image], threads: [Thread]) {
        self.images = images
        self.threads = threads
    }

    package struct Image: Codable, Hashable, Sendable {
        package let name: String
        package let uuid: UUID?

        package init(name: String, uuid: UUID?) {
            self.name = name
            self.uuid = uuid
        }
    }

    package struct Thread: Codable, Equatable, Sendable {
        package let attributed: Bool
        package let frames: [Frame]
    }

    package struct Frame: Equatable, Sendable {
        package let image: Int?
        package let offset: UInt64
    }
}

extension Backtrace.Frame: Codable {
    package init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        image = container.count == 2 ? try container.decode(Int.self) : nil
        offset = try container.decode(UInt64.self)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        if let image {
            try container.encode(image)
        }
        try container.encode(offset)
    }
}
