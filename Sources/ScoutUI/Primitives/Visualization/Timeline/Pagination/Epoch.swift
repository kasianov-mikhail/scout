//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

// A fresh identity minted on each reload or lane reset. An in-flight async
// step snapshots the current epoch, then compares its snapshot against the
// live value after each suspension to tell whether a newer reload has
// superseded it and the step should bail out.
struct Epoch: Equatable {
    private let id = UUID()
}
