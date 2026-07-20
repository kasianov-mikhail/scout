//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct GlobalSearchRow: View {
    let hit: GlobalSearchHit
    let query: String

    var body: some View {
        Row {
            Text(highlightedTitle)
            Spacer()
            GlobalSearchBadge(category: hit.category)
        } destination: {
            destination
        }
    }

    private var highlightedTitle: AttributedString {
        let font: Font = hit.category.isMonospaced ? .codeChip : .body

        var string = AttributedString(hit.title)
        string.font = font

        let text = query.trimmingCharacters(in: .whitespaces)
        if !text.isEmpty, let range = string.range(of: text, options: .caseInsensitive) {
            string[range].font = font.weight(.bold)
            string[range].foregroundColor = .blue
        }

        return string
    }

    @ViewBuilder private var destination: some View {
        switch hit {
        case .event(let name):
            EventStatList(eventName: name, range: Calendar.utc.defaultRange)
        case .metric(let name, let telemetry):
            MetricSearchDetail(name: name, telemetry: telemetry)
        case .endpoint(let name):
            EndpointSearchDetail(name: name)
        case .device(let device):
            DeviceDetailView(device: device)
        case .release(let release):
            VersionDetailView(release: release)
        case .crash(let group):
            CrashGroupDetailView(group: group)
        case .hang(let group):
            HangGroupDetailView(group: group)
        }
    }
}

struct GlobalSearchBadge: View {
    let category: GlobalSearchCategory

    var body: some View {
        Text(verbatim: category.title.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(category.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(category.color.opacity(0.14)))
    }
}

#Preview {
    NavigationStack {
        List {
            GlobalSearchRow(hit: .event(name: "session_start"), query: "ses")
            GlobalSearchRow(hit: .metric(name: "session_duration", telemetry: .timer), query: "ses")
            GlobalSearchRow(hit: .endpoint(name: "GET /v1/sessions"), query: "ses")

            if let device = [DeviceSummary].samples.first {
                GlobalSearchRow(hit: .device(device), query: "iphone")
            }
            if let release = [ReleaseHealth].samples.first {
                GlobalSearchRow(hit: .release(release), query: "3.2")
            }
            if let group = IncidentGroup.groups(from: [Crash].samples).first {
                GlobalSearchRow(hit: .crash(group), query: "range")
            }
            if let group = IncidentGroup.groups(from: [Hang].samples).first {
                GlobalSearchRow(hit: .hang(group), query: "main")
            }
        }
        .listStyle(.plain)
        .environmentObject(Tint())
    }
}
