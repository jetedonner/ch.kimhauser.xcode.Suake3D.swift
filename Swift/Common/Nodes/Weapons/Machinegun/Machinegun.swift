//
//  Machinegun.swift
//  Suake3D
//
//  Created by dave on 26.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

class Machinegun: WeaponBase{
    
    convenience init(_game: GameViewController){
        self.init()
        self.game = _game
    }
    
    required override init(){
        super.init()
        self.initWeapon(gunName: DbgMsgs.machinegun, soundType: .rifle, initAmmoCount: DbgVars.initMachinegunAmmo)
    }
    
    override func fireSpecificShot()->MachinegunBullet{
        return MachinegunBullet(_game: self.game)
    }
    
    func addSingleBullet(pos:SCNVector3, vect:SCNVector3)->MachinegunBullet{
        let bulletNode = MachinegunBullet(_game: self.game)
        bulletNode.position = pos
        bulletNode.position.y = 2
        bulletNode.position.z += 1
        bulletNode.applyForceToBullet(blt: bulletNode, vect: vect)
        self.firedShots.append(bulletNode)
        self.game.gameView.scene?.rootNode.addChildNode(bulletNode)
        return bulletNode
    }
}
