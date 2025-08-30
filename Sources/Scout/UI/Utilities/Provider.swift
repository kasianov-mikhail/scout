//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@MainActor
protocol Provider {
    associatedtype DataType

    var data: DataType? { get }

    func fetch(in database: DatabaseController) async
}

extension Provider {
    func fetchIfNeeded(in database: DatabaseController) async {
        if data == nil {
            await fetch(in: database)
        }
    }
}
