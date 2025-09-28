//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricsView<T: MatrixValue>: View {
    let matrices: [Matrix<GridCell<T>>]

    var body: some View {
        Text(String(matrices.count).uppercased())
            .font(.largeTitle)
            .bold()
            .navigationTitle(matrices[0].name)
    }
}
