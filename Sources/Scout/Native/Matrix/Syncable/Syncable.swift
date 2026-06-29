//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

protocol Syncable: SyncableObject {
    typealias Key = PartialKeyPath<Self>

    static var batchKeys: [Key] { get }
}

extension EventObject: Syncable {
    static var batchKeys: [Key] { [\.week, \.name] }
}

extension UserActivityObject: Syncable {
    static var batchKeys: [Key] { [\.month] }
}

extension CrashObject: Syncable {
    static var batchKeys: [Key] { [\.week, \.appVersion] }
}

extension SessionObject: Syncable {
    static var batchKeys: [Key] { [\.week, \.appVersion] }
}

extension DeviceObject: Syncable {
    static var batchKeys: [Key] { [\.week] }
}

extension InstallObject: Syncable {
    static var batchKeys: [Key] { [\.week] }
}

extension LaunchObject: Syncable {
    static var batchKeys: [Key] { [\.week] }
}

extension VersionObject: Syncable {
    static var batchKeys: [Key] { [\.week] }
}

extension DoubleMetricsObject: Syncable {
    static var batchKeys: [Key] { [\.week, \.telemetry, \.name] }
}

extension IntMetricsObject: Syncable {
    static var batchKeys: [Key] { [\.week, \.telemetry, \.name] }
}
