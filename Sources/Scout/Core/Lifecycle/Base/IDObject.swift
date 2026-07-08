//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(IDObject)
class IDObject: DateObject {
    @NSManaged var device: DeviceObject?
    @NSManaged var install: InstallObject?
    @NSManaged var launch: LaunchObject?

    override func awakeFromInsert() {
        super.awakeFromInsert()

        guard let context = managedObjectContext, let coordinator = context.persistentStoreCoordinator else { return }
        let hub = coordinator.hubObjectIDs

        device = IDs.resolve(hub.device, as: DeviceObject.self, in: context)
        install = IDs.resolve(hub.install, as: InstallObject.self, in: context)
        launch = IDs.resolve(hub.launch, as: LaunchObject.self, in: context)
    }

    var deviceIDString: String { device?.deviceID.uuidString ?? "" }
    var installIDString: String { install?.installID.uuidString ?? "" }
    var launchIDString: String { launch?.launchID.uuidString ?? "" }

    override var metadata: [String: Any] {
        var fields = super.metadata
        fields["device_id"] = deviceIDString
        fields["install_id"] = installIDString
        fields["launch_id"] = launchIDString
        fields["version"] = 1
        return fields
    }
}
