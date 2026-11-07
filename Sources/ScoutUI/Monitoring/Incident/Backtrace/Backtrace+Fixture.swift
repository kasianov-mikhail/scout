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
    static let sampleAppUUID = UUID(uuidString: "4F2A1C9E-7B3D-3A11-8E5C-2D9F6B1AC19E") ?? UUID()

    static var sample: Backtrace {
        Backtrace(
            images: [
                Backtrace.Image(name: "MyApp", uuid: sampleAppUUID),
                Backtrace.Image(name: "CoreFoundation", uuid: nil),
                Backtrace.Image(name: "libobjc.A.dylib", uuid: nil),
                Backtrace.Image(name: "UIKitCore", uuid: nil),
                Backtrace.Image(name: "QuartzCore", uuid: nil),
                Backtrace.Image(name: "GraphicsServices", uuid: nil),
            ],
            threads: [
                Backtrace.Thread(
                    attributed: true,
                    frames: [
                        Backtrace.Frame(image: 1, offset: 0),
                        Backtrace.Frame(image: 2, offset: 0),
                        Backtrace.Frame(image: 1, offset: 0),
                        Backtrace.Frame(image: 0, offset: 0x3010),
                        Backtrace.Frame(image: 0, offset: 0x4010),
                        Backtrace.Frame(image: 3, offset: 0),
                        Backtrace.Frame(image: 3, offset: 0),
                        Backtrace.Frame(image: 3, offset: 0),
                        Backtrace.Frame(image: 4, offset: 0),
                        Backtrace.Frame(image: 1, offset: 0),
                        Backtrace.Frame(image: 5, offset: 0),
                        Backtrace.Frame(image: 3, offset: 0),
                        Backtrace.Frame(image: 0, offset: 0xC010),
                    ]
                )
            ]
        )
    }

    static var hangSample: Backtrace {
        Backtrace(
            images: [
                Backtrace.Image(name: "MyApp", uuid: sampleAppUUID),
                Backtrace.Image(name: "CoreFoundation", uuid: nil),
                Backtrace.Image(name: "UIKitCore", uuid: nil),
                Backtrace.Image(name: "QuartzCore", uuid: nil),
                Backtrace.Image(name: "GraphicsServices", uuid: nil),
                Backtrace.Image(name: "libsystem_kernel.dylib", uuid: nil),
                Backtrace.Image(name: "Foundation", uuid: nil),
            ],
            threads: [
                Backtrace.Thread(
                    attributed: true,
                    frames: [
                        Backtrace.Frame(image: 5, offset: 0),
                        Backtrace.Frame(image: 5, offset: 0),
                        Backtrace.Frame(image: 6, offset: 0),
                        Backtrace.Frame(image: 0, offset: 0x3010),
                        Backtrace.Frame(image: 0, offset: 0x4010),
                        Backtrace.Frame(image: 2, offset: 0),
                        Backtrace.Frame(image: 2, offset: 0),
                        Backtrace.Frame(image: 2, offset: 0),
                        Backtrace.Frame(image: 3, offset: 0),
                        Backtrace.Frame(image: 1, offset: 0),
                        Backtrace.Frame(image: 4, offset: 0),
                        Backtrace.Frame(image: 2, offset: 0),
                        Backtrace.Frame(image: 0, offset: 0xC010),
                    ]
                )
            ]
        )
    }

    static var resourceSample: Backtrace {
        Backtrace(
            images: [
                Backtrace.Image(name: "MyApp", uuid: sampleAppUUID),
                Backtrace.Image(name: "CoreGraphics", uuid: nil),
                Backtrace.Image(name: "UIKitCore", uuid: nil),
                Backtrace.Image(name: "libdispatch.dylib", uuid: nil),
                Backtrace.Image(name: "libsystem_pthread.dylib", uuid: nil),
            ],
            threads: [
                Backtrace.Thread(
                    attributed: true,
                    frames: [
                        Backtrace.Frame(image: 1, offset: 0),
                        Backtrace.Frame(image: 1, offset: 0),
                        Backtrace.Frame(image: 2, offset: 0),
                        Backtrace.Frame(image: 0, offset: 0x3010),
                        Backtrace.Frame(image: 0, offset: 0x4010),
                        Backtrace.Frame(image: 0, offset: 0x5010),
                        Backtrace.Frame(image: 3, offset: 0),
                        Backtrace.Frame(image: 3, offset: 0),
                        Backtrace.Frame(image: 3, offset: 0),
                        Backtrace.Frame(image: 3, offset: 0),
                        Backtrace.Frame(image: 3, offset: 0),
                        Backtrace.Frame(image: 3, offset: 0),
                        Backtrace.Frame(image: 4, offset: 0),
                    ]
                )
            ]
        )
    }
}
