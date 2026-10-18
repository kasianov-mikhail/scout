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

extension Backtrace {
    init(addresses: [UInt64], images: [LoadedImage]) {
        var table = ImageTable()
        let frames = addresses.map { address in
            guard let image = images.first(where: { $0.contains(address: address) }) else {
                return Frame(image: nil, offset: address)
            }
            let index = table.index(image: Image(name: image.name, uuid: image.uuid))
            return Frame(image: index, offset: address - image.base)
        }
        self.init(images: table.images, threads: [Thread(attributed: true, frames: frames)])
    }

    init(stacks: [[MetricKitStackTree.Frame]], attributed: Int) {
        var table = ImageTable()
        let threads = stacks.enumerated().map { index, stack in
            Thread(attributed: index == attributed, frames: stack.map { table.frame(stackFrame: $0) })
        }
        self.init(images: table.images, threads: threads)
    }
}

private struct ImageTable {
    private(set) var images: [Backtrace.Image] = []
    private var indices: [Backtrace.Image: Int] = [:]

    mutating func index(image: Backtrace.Image) -> Int {
        if let index = indices[image] {
            return index
        }
        images.append(image)
        indices[image] = images.count - 1
        return images.count - 1
    }

    mutating func frame(stackFrame: MetricKitStackTree.Frame) -> Backtrace.Frame {
        guard let name = stackFrame.binaryName, let offset = stackFrame.offsetIntoBinaryTextSegment else {
            return Backtrace.Frame(image: nil, offset: stackFrame.address ?? 0)
        }
        return Backtrace.Frame(image: index(image: Backtrace.Image(name: name, uuid: stackFrame.binaryUUID)), offset: offset)
    }
}
