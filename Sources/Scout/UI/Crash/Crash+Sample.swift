//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Crash {
    static var sampleRecords: [CKRecord] {
        let crashes: [(name: String, reason: String?)] = [
            ("NSInternalInconsistencyException", "Invalid update: invalid number of rows"),
            ("SIGSEGV", nil),
            ("NSRangeException", "Index 5 beyond bounds [0 .. 3]"),
            ("EXC_BAD_ACCESS", "Attempted to dereference garbage pointer"),
            ("NSInvalidArgumentException", "Unrecognized selector sent to instance"),
            ("SIGABRT", "Abort trap 6"),
        ]

        return crashes.enumerated().map { index, crash in
            let record = CKRecord(recordType: "Crash", recordID: CKRecord.ID())
            record["name"] = crash.name
            record["reason"] = crash.reason
            record["date"] = Date().addingTimeInterval(TimeInterval(-index * 7200))
            record["uuid"] = UUID().uuidString
            record["user_id"] = UUID().uuidString
            record["launch_id"] = UUID().uuidString

            let stackTrace = [
                "0   CoreFoundation    0x00000001a3b8f4e0 __exceptionPreprocess + 220",
                "1   libobjc.A.dylib   0x00000001a38a5a70 objc_exception_throw + 60",
                "2   CoreFoundation    0x00000001a3c9e7d0 -[__NSArrayM objectAtIndexedSubscript:] + 228",
                "3   MyApp             0x0000000104a8c3e0 ViewController.viewDidLoad() + 120",
                "4   UIKitCore         0x00000001a7d4e2b0 -[UIViewController _sendViewDidLoadWithAppearanceProxyObjectTaggingEnabled] + 100",
            ]
            record["stack_trace"] = try! JSONEncoder().encode(stackTrace) as CKRecordValue

            return record
        }
    }
}
