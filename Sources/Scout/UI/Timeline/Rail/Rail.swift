//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// A device's full lifecycle tree: installs, their launches, their sessions,
/// and the events and crashes inside each session.
///
/// Invariant: every level is sorted ascending by date — `Rail.init` sorts the
/// tree once at construction, so consumers (rows, split, export) can rely on
/// the order instead of re-sorting.
///
struct Rail: Identifiable {
    let device: Device
    var installs: [InstallRoot]

    var id: RecordID { device.id }
}

struct InstallRoot: Identifiable {
    let install: Install
    let launches: [LaunchRoot]

    var id: RecordID { install.id }
}

struct LaunchRoot: Identifiable {
    let launch: Launch
    let sessions: [SessionRoot]

    var id: RecordID { launch.id }
}

struct SessionRoot: Identifiable {
    let session: Session
    let events: [Event]
    let crashes: [Crash]

    var id: RecordID { session.id }
}
