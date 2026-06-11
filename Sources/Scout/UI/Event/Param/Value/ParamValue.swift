//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

/// A display-oriented classification of a raw parameter value, mirroring the
/// `Logger.MetadataValue` cases the value originated from.
///
/// Parameters arrive as plain strings, so the original case is recovered from the
/// textual shape: JSON objects and arrays become `.dictionary` and `.array`,
/// recognizable scalars become `.stringConvertible`, and everything else stays `.string`.
///
enum ParamValue: Hashable {
    /// A plain string value.
    case string(String)

    /// A scalar that reads as a typed value, such as a number or a URL.
    case stringConvertible(Convertible)

    /// A dictionary value with entries ordered by key.
    case dictionary([Entry])

    /// An array of values.
    case array([ParamValue])
}

extension ParamValue {
    /// A typed scalar recognized from its textual shape.
    enum Convertible: Hashable {
        case number(String)
        case boolean(Bool)
        case uuid(String)
        case url(String)
        case date(String)
    }

    /// A key–value pair of a dictionary value.
    struct Entry: Hashable, Identifiable {
        let key: String
        let value: ParamValue

        var id: String { key }
    }
}
