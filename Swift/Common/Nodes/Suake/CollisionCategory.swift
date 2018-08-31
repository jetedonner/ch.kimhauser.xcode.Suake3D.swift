//
//  CollisionCategory.swift
//  Suake3D
//
//  Created by dave on 11.04.18.
//  Copyright © 2018 DaVe Inc. All rights reserved.
//

import Foundation

struct CollisionCategory {
    static let SuakeCategory = 1                // 1 << 0
    static let MouseCategory = 2                // 1 << 1
    static let PortalInCategory = 4             // 1 << 2
    static let PortalOutCategory = 8            // 1 << 3
    static let PelletCategory = 16              // 1 << 4
    static let RocketLauncherCategory = 32      // 1 << 5
    static let RampCategory = 64                // 1 << 6
    static let MachineGunCategory = 128         // 1 << 7
    static let RocketCategory = 256             // 1 << 8
    static let FloorCategory = 512              // 1 << 9
    static let ShotgunCategory = 1024           // 1 << 10
    static let SuakeOpCategory = 2048           // 1 << 11
    static let RailShotCategory = 4096          // 1 << 12
    static let RailGunCategory = 8192           // 1 << 13
    static let FireCategory = 16384             // 1 << 14
    static let MachineGunBulletCategory = 32768 // 1 << 15
}
