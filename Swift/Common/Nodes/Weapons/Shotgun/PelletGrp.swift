//
//  BulletGrp.swift
//  Suake3D
//
//  Created by dave on 11.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

// Spheres that are shot at the "ships"
class PelletGrp: BulletBase{

    public var bulletsNode1:Pellet! // = addSingleBullet(pos: game.suake.suakeHead.presentation.position, vect: SCNVector3(x: 0, y: 0, z: 85))
    public var bulletsNode2:Pellet! // = addSingleBullet(pos: game.suake.suakeHead.presentation.position, vect: SCNVector3(x: -1, y: 0, z: 85))
    public var bulletsNode3:Pellet! // = addSingleBullet(pos: game.suake.suakeHead.presentation.position, vect: SCNVector3(x: 1, y: 0, z: 85))
    public var bulletsNode4:Pellet! // = addSingleBullet(pos: game.suake.suakeHead.presentation.position, vect: SCNVector3(x: 0.5, y: 1, z: 85))
    public var bulletsNode5:Pellet! // = addSingleBullet(pos: game.suake.suakeHead.presentation.position, vect: SCNVector3(x: -0.5, y: -1, z:
    
    //var game:GameViewController!
    var shotgun:Shotgun!
    
    convenience init(_game:GameViewController, _shotgun:Shotgun) {
        self.init()
        self.game = _game
        self.shotgun = _shotgun
        self.name = "PelletGroup"
    }
    
    required override init(){
        super.init()
    }
    
    func addShotgunShot(){
        /* SHOTGUN START */
        bulletsNode1 = addSingleBullet(pos: game.suake.suakeHead.presentation.position, vect: SCNVector3(x: 0, y: 0, z: shootingVelocity))
        bulletsNode2 = addSingleBullet(pos: game.suake.suakeHead.presentation.position, vect: SCNVector3(x: -1, y: 0, z: shootingVelocity))
        bulletsNode3 = addSingleBullet(pos: game.suake.suakeHead.presentation.position, vect: SCNVector3(x: 1, y: 0, z: shootingVelocity))
        bulletsNode4 = addSingleBullet(pos: game.suake.suakeHead.presentation.position, vect: SCNVector3(x: 0.5, y: 1, z: shootingVelocity))
        bulletsNode5 = addSingleBullet(pos: game.suake.suakeHead.presentation.position, vect: SCNVector3(x: -0.5, y: -1, z: shootingVelocity))
        let shotParticleSystem = SCNParticleSystem(named: "shotBurst2", inDirectory: nil)
        let shotParticleNode = SCNNode()
        shotParticleNode.addParticleSystem(shotParticleSystem!)
        shotParticleNode.position = game.suake.suakeHead.presentation.position
        self.addChildNode(shotParticleNode)
    }
    
    func addSingleBullet(pos:SCNVector3){
        addSingleBullet(pos: pos, vect: SCNVector3(x: 0, y: 0, z: shootingVelocity))
    }
    
    func addSingleBullet(pos:SCNVector3, vect:SCNVector3)->Pellet{
        let bulletsNode = Pellet()
        bulletsNode.position = pos
        bulletsNode.position.y += 5
        bulletsNode.position.z += 1
        applyForceToBullet(blt: bulletsNode, vect: vect)
        self.addChildNode(bulletsNode)
        return bulletsNode
    }
    
    func applyForceToBullet(blt:Pellet, vect:SCNVector3){
        blt.physicsBody?.applyForce(vect, asImpulse: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
