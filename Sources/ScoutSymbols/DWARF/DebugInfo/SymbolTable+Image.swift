//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import SymbolTable

extension SymbolTable {
    package init(image: MachOImage) throws {
        let info = try DebugInfo(image: image)
        self.init(uuid: image.uuid, functions: info.functions, lines: try LineTable(image: image).lines, inlines: info.inlines)
    }
}
