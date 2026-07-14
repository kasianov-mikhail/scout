//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutDB
import SwiftUI

extension View {
    /// Puts the in-flight request gauge in the trailing toolbar of internal builds.
    func requestGauge() -> some View {
        toolbar {
            if SystemInfo.isInternalBuild {
                ToolbarItem(placement: .topBarTrailing) {
                    RequestGauge()
                }
            }
        }
    }
}

struct RequestGauge: View {
    @ObservedObject var activity = RequestActivity.shared
    var updates: AsyncStream<Int> = cloudKitRequestActivity.updates

    private let sweep = 240.0 / 360
    private let rotation = 150.0
    private let width = 2.5

    var body: some View {
        ZStack {
            Arc(sweep: sweep)
                .stroke(.quaternary, style: StrokeStyle(lineWidth: width, lineCap: .round))
            Arc(sweep: sweep * activity.fraction)
                .stroke(
                    activity.isSaturated ? Color.red : .accentColor,
                    style: StrokeStyle(lineWidth: width, lineCap: .round)
                )
        }
        .rotationEffect(.degrees(rotation))
        .frame(width: 20, height: 20)
        .animation(.easeOut(duration: 0.2), value: activity.fraction)
        .accessibilityLabel(Text(verbatim: "\(activity.running) of \(activity.limit) requests in flight"))
        .task {
            await activity.track(updates)
        }
    }
}

private struct Arc: Shape {
    var sweep: Double

    var animatableData: Double {
        get { sweep }
        set { sweep = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Circle().trim(from: 0, to: sweep).path(in: rect)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @StateObject var activity = RequestActivity(limit: 8)

    NavigationStack {
        List {
            Text(verbatim: "Events")
            Text(verbatim: "Sessions")
        }
        .listStyle(.plain)
        .navigationTitle(en: "Home")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                RequestGauge(activity: activity, updates: AsyncStream { $0.yield(3) })
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "gearshape")
            }
        }
    }
}
