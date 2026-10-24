//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

extension Backtrace {
    static var sample: Backtrace {
        Backtrace(
            images: [
                Backtrace.Image(name: "MyApp", uuid: UUID(uuidString: "4F2A1C9E-7B3D-3A11-8E5C-2D9F6B1AC19E")),
                Backtrace.Image(name: "UIKitCore", uuid: UUID(uuidString: "9C1D2E3F-4A5B-3C6D-8E7F-0A1B2C3D4E5F")),
                Backtrace.Image(name: "libsystem_kernel.dylib", uuid: nil),
            ],
            threads: []
        )
    }
}
