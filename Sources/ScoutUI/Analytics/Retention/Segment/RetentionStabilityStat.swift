//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct RetentionStabilityStat: View {
    let segment: RetentionSegment
    let incident: IncidentKind

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: incident.title.uppercased()).font(.caption2).foregroundStyle(.secondary)
            Text(verbatim: segment.share(of: incident).formatted(.incidentRate))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(incident.color)
            Text(verbatim: "\(segment.count(of: incident)) of \(segment.size) installs")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 70)
    }
}

extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Percent {
    fileprivate static var incidentRate: FloatingPointFormatStyle<Double>.Percent {
        retentionRate.precision(.fractionLength(1))
    }
}

#Preview("RetentionStabilityStat") {
    let segment = RetentionCohort.samples[0].segments[2]

    HStack(spacing: 24) {
        RetentionStabilityStat(segment: segment, incident: .crash)
        RetentionStabilityStat(segment: segment, incident: .hang)
    }
    .padding()
}
