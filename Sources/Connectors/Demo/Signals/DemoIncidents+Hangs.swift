//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension DemoIncidents {
    static let hangSignatures: [(name: String, reason: String, frames: [String])] = [
        (
            "Main thread blocked", "Synchronous network request on the main queue",
            ["SyncManager.flush()", "URLSession.dataTask(with:)", "RunLoop.run()"]
        ),
        (
            "Main thread blocked", "Heavy image decode during scroll",
            ["ImageCache.decode(_:)", "UIImage.init(data:)", "CATransaction.commit()"]
        ),
        (
            "Main thread blocked", "Large Core Data fetch on the main context",
            ["Library.reload()", "NSManagedObjectContext.fetch(_:)", "sqlite3_step"]
        ),
        (
            "Main thread blocked", "JSON parse of a large payload",
            ["Importer.run()", "JSONSerialization.jsonObject(with:)", "memmove"]
        ),
    ]
}
