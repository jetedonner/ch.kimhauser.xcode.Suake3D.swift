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
        self.initWeapon(initAmmoCount: DbgVars.initRailgunAmmo)
    }
    
    override func fireSpecificShot()->RailgunBeam{
        game.showDbgMsg(dbgMsg: DbgMsgs.railgunFired)
        game.mediaManager.playSound(soundType: .railgun)
        let rgb:RailgunBeam = RailgunBeam(_game: self.game)
        rgb.addRailgunShot()
        return rgb
    }
    
    /*func addSingleBullet(pos:SCNVector3, vect:SCNVector3)->RailgunBeam{
        let bulletNode = MachinegunBullet(_game: self.game)
        bulletNode.position = pos
        bulletNode.position.y = 2
        bulletNode.position.z += 1
        bulletNode.applyForceToBullet(blt: bulletNode, vect: vect)
        self.firedShots.append(bulletNode)
        self.game.gameView.scene?.rootNode.addChildNode(bulletNode)
        return bulletNode
    }*/
}
