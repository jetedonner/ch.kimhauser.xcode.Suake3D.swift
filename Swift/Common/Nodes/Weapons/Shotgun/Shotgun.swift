//
//  Machinegun.swift
//  Suake3D
//
//  Created by dave on 26.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

class Shotgun: WeaponBase {
    
    convenience init(_game: GameViewController){
        self.init()
        self.game = _game
    }
    
    required override init(){
        super.init()
        // Init gun specific var
        self.initWeapon(initAmmoCount: DbgVars.initShotgunAmmo)
    }
    
    override func fireSpecificShot()->PelletGrp{
        game.showDbgMsg(dbgMsg: DbgMsgs.shotgunFired)
        game.mediaManager.playSound(soundType: .shotgun)
        let pltGrp:PelletGrp = PelletGrp(_game: self.game, _shotgun: self)
        pltGrp.addShotgunShot()
        return pltGrp
    }
    
    func addSingleBullet(pos:SCNVector3, vect:SCNVector3)->Pellet{
        let bulletNode = Pellet(_game: self.game)
        bulletNode.position = pos
        bulletNode.position.y = 2
        bulletNode.position.z += 1
        bulletNode.physicsBody?.applyForce(vect, asImpulse: true)
        self.firedShots.append(bulletNode)
        self.game.gameView.scene?.rootNode.addChildNode(bulletNode)
        return bulletNode
    }
}
