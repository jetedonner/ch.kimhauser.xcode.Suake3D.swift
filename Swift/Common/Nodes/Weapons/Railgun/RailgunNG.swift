//
//  Machinegun.swift
//  Suake3D
//
//  Created by dave on 26.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

class RailgunNG: WeaponBase{
    
    convenience init(_game: GameViewController){
        self.init()
        self.game = _game
    }
    
    required override init(){
        super.init()
        self.initWeapon(gunName: DbgMsgs.railgun, soundType: .railgun, initAmmoCount: DbgVars.initRailgunAmmo)
    }
    
    override func fireSpecificShot()->RailgunBeam{
        let rgb:RailgunBeam = RailgunBeam(_game: self.game)
        rgb.addRailgunShot()
        return rgb
    }
}
