//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A structure that encapsulates various identifiers used within the Scout application.
/// This structure is intended to provide a centralized location for managing and accessing
/// different types of IDs, ensuring consistency and reducing the risk of hardcoding values
/// throughout the codebase.
///
struct IDs {
    static let session = UUID()

    static let user: UUID = {
        let userIDString = UserDefaults.standard.string(forKey: "scout_log_user_id")
        let userID = userIDString.flatMap { UUID(uuidString: $0) } ?? UUID()
        UserDefaults.standard.set(userID.uuidString, forKey: "scout_log_user_id")
        return userID
    }()
}
