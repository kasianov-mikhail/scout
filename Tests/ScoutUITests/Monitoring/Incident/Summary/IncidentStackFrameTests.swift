//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

@Suite("IncidentStackFrame")
struct IncidentStackFrameTests {
    @Test("A frame splits into index, image and symbol")
    func parsesFrame() {
        let frame = IncidentStackFrame.frames(from: ["0   CoreFoundation        0x0 __exceptionPreprocess + 164"])[0]

        #expect(frame.index == "0")
        #expect(frame.image == "CoreFoundation")
        #expect(frame.symbol == "__exceptionPreprocess + 164")
        #expect(!frame.isApp)
    }

    @Test("An app image marks the frame as app")
    func marksAppFrame() {
        let frame = IncidentStackFrame.frames(from: ["3   MyApp                 0x0 FeedViewController.row(at:) + 88"])[0]

        #expect(frame.image == "MyApp")
        #expect(frame.symbol == "FeedViewController.row(at:) + 88")
        #expect(frame.isApp)
    }

    @Test("A library image stays a system frame")
    func marksSystemFrame() {
        let frame = IncidentStackFrame.frames(from: ["4   libsystem_kernel.dylib 0x0 mach_msg + 1"])[0]

        #expect(frame.image == "libsystem_kernel.dylib")
        #expect(!frame.isApp)
    }

    @Test("A line without a frame shape keeps its text")
    func keepsPlainLine() {
        let frame = IncidentStackFrame.frames(from: ["not a frame"])[0]

        #expect(frame.index == "0")
        #expect(frame.image == nil)
        #expect(frame.symbol == "not a frame")
    }

    @Test("Only the requested number of frames is kept")
    func limitsFrames() {
        let lines = (0..<10).map { "\($0)   MyApp   0x0 frame\($0) + 1" }

        #expect(IncidentStackFrame.frames(from: lines).count == 6)
        #expect(IncidentStackFrame.frames(from: lines, limit: 3).count == 3)
    }
}
