//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct MetricKitStackTree: Decodable {
    let callStacks: [CallStack]

    struct CallStack: Decodable {
        let threadAttributed: Bool
        let callStackRootFrames: [Frame]

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            threadAttributed = try container.decodeIfPresent(Bool.self, forKey: .threadAttributed) ?? false
            callStackRootFrames = try container.decodeIfPresent([Frame].self, forKey: .callStackRootFrames) ?? []
        }

        private enum CodingKeys: String, CodingKey {
            case threadAttributed, callStackRootFrames
        }
    }

    struct Frame: Decodable, Equatable, Sendable {
        let binaryName: String?
        let offsetIntoBinaryTextSegment: UInt64?
        let sampleCount: Int
        let subFrames: [Frame]

        private enum CodingKeys: String, CodingKey {
            case binaryName, offsetIntoBinaryTextSegment, sampleCount, subFrames
        }
    }
}

extension MetricKitStackTree.Frame {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        binaryName = try container.decodeIfPresent(String.self, forKey: .binaryName)
        offsetIntoBinaryTextSegment = try container.decodeIfPresent(UInt64.self, forKey: .offsetIntoBinaryTextSegment)
        sampleCount = try container.decodeIfPresent(Int.self, forKey: .sampleCount) ?? 0
        subFrames = try container.decodeIfPresent([Self].self, forKey: .subFrames) ?? []
    }
}

extension MetricKitStackTree {
    init(json: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: json)
    }

    var crashedFrames: [Frame] {
        let stack = callStacks.first(where: \.threadAttributed) ?? callStacks.first
        return path(root: stack?.callStackRootFrames.first) { $0.first }
    }

    var heaviestFrames: [Frame] {
        path(root: callStacks.flatMap(\.callStackRootFrames).heaviest) { $0.heaviest }
    }

    private func path(root: Frame?, next: ([Frame]) -> Frame?) -> [Frame] {
        var frames: [Frame] = []
        var current = root

        while let frame = current {
            frames.append(frame)
            current = next(frame.subFrames)
        }
        return frames
    }
}

extension MetricKitStackTree.Frame {
    var binary: String {
        binaryName ?? "???"
    }

    var offset: String {
        offsetIntoBinaryTextSegment.map { "0x\(String($0, radix: 16))" } ?? "???"
    }
}

extension [MetricKitStackTree.Frame] {
    fileprivate var heaviest: MetricKitStackTree.Frame? {
        self.max { $0.sampleCount < $1.sampleCount }
    }
}
