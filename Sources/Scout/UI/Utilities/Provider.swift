//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@MainActor protocol Provider: AnyObject {
    associatedtype DataType

    var data: DataType? { set get }

    func fetch(in database: DatabaseController) async
}

extension Provider {
    func fetchAgain(in database: DatabaseController) async {
        data = nil
        await fetch(in: database)
    }

    func fetchIfNeeded(in database: DatabaseController) async {
        if data == nil {
            await fetch(in: database)
        }
    }
}
