//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

protocol DataProvider {
    associatedtype DataType
    
    var data: DataType? { get }
    
    func fetchIfNeeded(in database: DatabaseController) async
    func fetch(in database: DatabaseController) async
}

extension DataProvider {
    func fetchIfNeeded(in database: DatabaseController) async {
        if data == nil {
            await fetch(in: database)
        }
    }
}