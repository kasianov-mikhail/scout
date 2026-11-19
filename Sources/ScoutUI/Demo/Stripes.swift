//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Stripes: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for y in stride(from: rect.maxY, to: rect.minY, by: -4) {
            path.addRect(CGRect(x: rect.minX, y: y - 2, width: rect.width, height: 2))
        }
        return path
    }
}
