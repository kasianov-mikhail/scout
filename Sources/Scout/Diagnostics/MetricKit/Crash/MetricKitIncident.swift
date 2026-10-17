//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol MetricKitIncident: IncidentContent {
    var window: DateInterval { get }
    var frames: [MetricKitStackTree.Frame] { get }
}

extension MetricKitIncident {
    var stackTrace: [String] {
        frames.enumerated().map { index, frame in
            StackWalker.offsetFrame(index: index, image: frame.binary, offset: frame.offset)
        }
    }

    var fingerprint: String {
        CrashFingerprint(name: name, offsets: frames.map { "\($0.binary) + \($0.offset)" }).value
    }

    var source: IncidentSource {
        .metricKit(windowStart: window.duration > 0 ? window.start : nil)
    }

    var date: Date {
        window.end
    }
}
