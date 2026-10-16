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
        let subFrames: [Frame]

        private enum CodingKeys: String, CodingKey {
            case binaryName, offsetIntoBinaryTextSegment, subFrames
        }
    }
}

extension MetricKitStackTree.Frame {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        binaryName = try container.decodeIfPresent(String.self, forKey: .binaryName)
        offsetIntoBinaryTextSegment = try container.decodeIfPresent(UInt64.self, forKey: .offsetIntoBinaryTextSegment)
        subFrames = try container.decodeIfPresent([Self].self, forKey: .subFrames) ?? []
    }
}

extension MetricKitStackTree {
    init(json: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: json)
    }

    var crashedFrames: [Frame] {
        let stack = callStacks.first(where: \.threadAttributed) ?? callStacks.first
        var frames: [Frame] = []
        var next = stack?.callStackRootFrames.first

        while let frame = next {
            frames.append(frame)
            next = frame.subFrames.first
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
