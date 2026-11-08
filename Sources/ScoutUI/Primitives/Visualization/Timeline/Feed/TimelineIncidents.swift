//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

struct TimelineIncidents {
    var crashes: [Crash] = []
    var hangs: [Hang] = []
    var resources: [ResourceException] = []
    var versions: [Version] = []
}
