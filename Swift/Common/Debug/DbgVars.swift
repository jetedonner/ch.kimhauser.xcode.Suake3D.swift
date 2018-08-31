//
//  DbgVars.swift
//  Suake3D
//
//  Created by dave on 14.07.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

class DbgVars{
    static let autoStart:Bool = false
    static let showMap:Bool = true
    static let showCh:Bool = false
    static let showArrows:Bool = true
    static let msgShowTime:TimeInterval = 0.35
    static let clickShotEnabled:Bool = true
    static let bgMusicOn:Bool = true
    static let showFire:Bool = true
    static let showWalls:Bool = true
    static let vsKI:Bool = true
    
    // Debug places on board
    static let goodyPos:SCNVector3 = SCNVector3(x: 5, y: 0, z: 6)
    static let oppPos:SCNVector3 = SCNVector3(x: 3, y: 0, z: 4)
    
    // Dbg Portal positions
    static let portGrpIn1:SCNVector3 = SCNVector3(x: 0, y: 0, z: 3)
    static let portGrpOut1:SCNVector3 = SCNVector3(x: 3, y: 0, z: 3)
    
    static let portGrpIn2:SCNVector3 = SCNVector3(x: 2, y: 0, z: 1)
    static let portGrpOut2:SCNVector3 = SCNVector3(x: 30, y: 0, z: 1)
    
    static let portGrpIn3:SCNVector3 = SCNVector3(x: -2, y: 0, z: 2)
    static let portGrpOut3:SCNVector3 = SCNVector3(x: -30, y: 0, z: 1)
    
    static let machinegunPickup:SCNVector3 = SCNVector3(x: 3, y: 8, z: 4)
    static let shotgunPickup:SCNVector3 = SCNVector3(x: 3, y: 5, z: 5)
    static let rocketLauncherPickup:SCNVector3 = SCNVector3(x: 3, y: 5, z: 6)
    static let railgunPickup:SCNVector3 = SCNVector3(x: 3, y: 8, z: 7)
    
    static let initMachinegunAmmo:Int = 10
    static let initShotgunAmmo:Int = 5
    static let initRocketlauncherAmmo:Int = 3
    static let initRailgunAmmo:Int = 2
}
