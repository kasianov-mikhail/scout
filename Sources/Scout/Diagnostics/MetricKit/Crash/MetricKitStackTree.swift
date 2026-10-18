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
        let binaryUUID: UUID?
        let offsetIntoBinaryTextSegment: UInt64?
        let address: UInt64?
        let sampleCount: Int
        let subFrames: [Frame]

        private enum CodingKeys: String, CodingKey {
            case binaryName, binaryUUID, offsetIntoBinaryTextSegment, address, sampleCount, subFrames
        }
    }
}

extension MetricKitStackTree.Frame {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        binaryName = try container.decodeIfPresent(String.self, forKey: .binaryName)
        binaryUUID = try container.decodeIfPresent(String.self, forKey: .binaryUUID).flatMap(UUID.init)
        offsetIntoBinaryTextSegment = try container.decodeIfPresent(UInt64.self, forKey: .offsetIntoBinaryTextSegment)
        address = try container.decodeIfPresent(UInt64.self, forKey: .address)
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
        keptStacks.map { CrashThread(crashed: $0.index == crashedIndex, frames: $0.frames.stackTrace) }
    }

    var backtrace: Backtrace {
        Backtrace(stacks: keptStacks.map(\.frames), attributed: keptStacks.firstIndex { $0.index == crashedIndex } ?? 0)
    }

    private var keptStacks: [KeptStack] {
        callStacks.enumerated()
            .filter { $0.offset < threadLimit || $0.offset == crashedIndex }
            .map { KeptStack(index: $0.offset, frames: Array($0.element.frames.prefix(threadFrameLimit))) }
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

private struct KeptStack {
    let index: Int
    let frames: [MetricKitStackTree.Frame]
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
