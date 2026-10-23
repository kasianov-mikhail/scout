//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if os(macOS)
    import SwiftUI

    extension ToolbarPlacement {
        static var navigationBar: ToolbarPlacement { .windowToolbar }
    }
#endif
