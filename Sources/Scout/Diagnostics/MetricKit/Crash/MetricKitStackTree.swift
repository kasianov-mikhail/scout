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
        crashedStack?.frames ?? []
    }

    var heaviestFrames: [Frame] {
        path(root: callStacks.flatMap(\.callStackRootFrames).heaviest) { $0.heaviest }
    }

    var threads: [CrashThread] {
        callStacks.enumerated()
            .filter { $0.offset < threadLimit || $0.offset == crashedIndex }
            .map { index, stack in
                CrashThread(crashed: index == crashedIndex, frames: Array(stack.frames.prefix(threadFrameLimit)).stackTrace)
            }
    }

    private var crashedIndex: Int {
        callStacks.firstIndex(where: \.threadAttributed) ?? 0
    }

    private var crashedStack: CallStack? {
        callStacks.indices.contains(crashedIndex) ? callStacks[crashedIndex] : nil
    }
}

extension MetricKitStackTree.CallStack {
    fileprivate var frames: [MetricKitStackTree.Frame] {
        path(root: callStackRootFrames.first) { $0.first }
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
    var stackTrace: [String] {
        enumerated().map { index, frame in
            StackWalker.offsetFrame(index: index, image: frame.binary, offset: frame.offset)
        }
    }

    fileprivate var heaviest: MetricKitStackTree.Frame? {
        self.max { $0.sampleCount < $1.sampleCount }
    }
}

private let threadLimit = 64
private let threadFrameLimit = 64

private func path(root: MetricKitStackTree.Frame?, next: ([MetricKitStackTree.Frame]) -> MetricKitStackTree.Frame?) -> [MetricKitStackTree.Frame] {
    var frames: [MetricKitStackTree.Frame] = []
    var current = root

    while let frame = current {
        frames.append(frame)
        current = next(frame.subFrames)
    }
    return frames
}
