//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

extension CGFloat {
    /// A timeline step: session start and end, app crashed, transitions between sessions.
    static let rowStep: CGFloat = 36

    /// A dense table row that is not tappable: day and hour tables, retention, Settings choices.
    static let rowTable: CGFloat = 40

    /// A standard row that is tappable: events, params, context and detail rows.
    static let rowRegular: CGFloat = 44

    /// A row with a title and a subtitle on two lines.
    static let rowSubtitle: CGFloat = 56

    /// A row with a title, a subtitle and a bar or a mini chart.
    static let rowChart: CGFloat = 64

    /// A line of 12–13 pt explanatory text.
    static let captionStep: CGFloat = 18

    /// A line of 12–13 pt monospaced code, such as a stack frame or a log line.
    static let codeStep: CGFloat = 20
}
