//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

enum ParamValue: Hashable {
    case string(String)

    case stringConvertible(Convertible)

    case dictionary([Entry])

    case array([ParamValue])
}

extension ParamValue {
    enum Convertible: Hashable {
        case number(String)
        case boolean(Bool)
        case uuid(String)
        case url(String)
        case date(String)
    }

    struct Entry: Hashable, Identifiable {
        let key: String
        let value: ParamValue

        var id: String { key }
    }
}
