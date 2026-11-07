//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct IncidentStackFrame: Identifiable {
    let index: String
    let image: String?
    let symbol: String
    let isApp: Bool

    var id: String {
        "\(index)|\(image ?? "")|\(symbol)"
    }
}

extension IncidentStackFrame {
    static func frames(from lines: [String], limit: Int = 6) -> [IncidentStackFrame] {
        lines.prefix(limit).enumerated().map { offset, line in
            frame(line, offset: offset)
        }
    }

    private static func frame(_ line: String, offset: Int) -> IncidentStackFrame {
        let parts = line.split(whereSeparator: \.isWhitespace).map(String.init)
        guard parts.count >= 2, Int(parts[0]) != nil else {
            return IncidentStackFrame(index: "\(offset)", image: nil, symbol: line, isApp: false)
        }

        let image = parts[1]
        var symbolParts = parts.dropFirst(2)
        if let address = symbolParts.first, address.hasPrefix("0x") {
            symbolParts = symbolParts.dropFirst()
        }
        let symbol = symbolParts.isEmpty ? line : symbolParts.joined(separator: " ")

        return IncidentStackFrame(
            index: parts[0],
            image: image,
            symbol: symbol,
            isApp: !systemImages.contains(image) && !image.hasPrefix("lib")
        )
    }

    private static let systemImages: Set<String> = [
        "CoreFoundation",
        "CoreGraphics",
        "CoreImage",
        "Combine",
        "Foundation",
        "FrontBoardServices",
        "GraphicsServices",
        "Metal",
        "QuartzCore",
        "SwiftUI",
        "UIKitCore",
        "libc++.1.dylib",
        "libdispatch.dylib",
        "libobjc.A.dylib",
        "libsystem_c.dylib",
        "libsystem_kernel.dylib",
        "libsystem_pthread.dylib",
    ]
}
