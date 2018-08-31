//
//  Machinegun.swift
//  Suake3D
//
//  Created by dave on 26.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

class Rocketlauncher: WeaponBase{
    
    convenience init(_game: GameViewController){
        self.init()
        self.game = _game
    }
    
    required override init(){
        super.init()
        
        self.initWeapon(gunName: DbgMsgs.rocketlauncher, soundType: .bottleRocket, initAmmoCount: DbgVars.initRocketlauncherAmmo)
    }
    
    override func fireSpecificShot()->RocketNode{
        let rocketNode:RocketNode = addRocket(pos: SCNVector3(x: 0, y: 0, z: 0), xDelta: 0.0)
        return rocketNode
    }
    
    func addRocket(pos:SCNVector3, xDelta:Float)->RocketNode{
        let rocketNode:RocketNode = RocketNode(_game: self.game)
        rocketNode.pos = pos
        rocketNode.position = pos
        if(game.suake.suakeHead.dir == .DOWN){
            rocketNode.shotParticleNode.position.z += 3.5
        }else if(game.suake.suakeHead.dir == .LEFT){
            rocketNode.shotParticleNode.position.x -= 3.5
        }else if(game.suake.suakeHead.dir == .RIGHT){
            rocketNode.shotParticleNode.position.z -= 3.5
        }
        var zVelocity:CGFloat = 0.0
        if(game.gameView.yPercent > 0.0){
            if(game.gameView.yPercent <= 1.0){
                zVelocity = CGFloat(game.gameView.yPercent) * rocketNode.shootingVelocity
            }else{
                zVelocity = 1.0
            }
        }
        rocketNode.physicsBody?.velocity = SCNVector3(x: CGFloat(game.gameView.xPercent) * rocketNode.shootingVelocity, y: zVelocity, z: CGFloat(game.gameView.zPercent) * rocketNode.shootingVelocity)
        var fo:SCNVector3 = SCNVector3(x: CGFloat(game.gameView.xPercent) * rocketNode.shootingVelocity, y: zVelocity, z: CGFloat(game.gameView.zPercent) * rocketNode.shootingVelocity)
        if(game.suake.suakeHead.dir == .DOWN){
            fo = SCNVector3(x: 0, y: 0, z: -1 * rocketNode.shootingVelocity)
            rocketNode.physicsBody?.velocity = SCNVector3(x: 0, y: 0, z: -85)
        }else if(game.suake.suakeHead.dir == .LEFT){
            fo = SCNVector3(x: rocketNode.shootingVelocity, y: 0, z: 0)
            rocketNode.physicsBody?.velocity = SCNVector3(x: 85, y: 0, z: 0)
        }else if(game.suake.suakeHead.dir == .RIGHT){
            fo = SCNVector3(x: -1 * rocketNode.shootingVelocity, y: 0, z: 0)
            rocketNode.physicsBody?.velocity = SCNVector3(x: -85, y: 0, z: 0)
        }
        rocketNode.physicsBody?.applyForce(fo, asImpulse: true)
        rocketNode.physicsBody?.categoryBitMask = CollisionCategory.RocketCategory
        rocketNode.physicsBody?.contactTestBitMask = CollisionCategory.RocketCategory|CollisionCategory.SuakeOpCategory|CollisionCategory.FloorCategory|CollisionCategory.PortalInCategory|CollisionCategory.SuakeCategory
        return rocketNode
    }

    func explodeRocket(rocketNode:RocketNode, targetNode:SCNNode, removeTargetNode:Bool){
        rocketNode.isTargetHit = true
        let exp = SCNParticleSystem()
        exp.loops = false
        exp.birthRate = 5000
        exp.emissionDuration = 0.01
        exp.spreadingAngle = 140
        exp.particleDiesOnCollision = true
        exp.particleLifeSpan = 0.5
        exp.particleLifeSpanVariation = 0.3
        exp.particleVelocity = 500
        exp.particleVelocityVariation = 3
        exp.particleSize = 0.05
        exp.stretchFactor = 0.05
        exp.particleColor = NSColor.orange
        let shotParticleNode = SCNNode()
        shotParticleNode.addParticleSystem(exp)
        if(removeTargetNode){
            shotParticleNode.position = targetNode.presentation.position
            targetNode.removeFromParentNode()
        }else{
            shotParticleNode.position = rocketNode.presentation.position
        }
        game.gameView.scene?.rootNode.addChildNode(shotParticleNode)
        try rocketNode.removeAllActions()
        try rocketNode.removeAllAnimations()
        try rocketNode.removeAllAudioPlayers()
        try rocketNode.removeAllParticleSystems()
        if var rocketNode = rocketNode as? SCNNode {
            try rocketNode.removeFromParentNode()
        }
        game.mediaManager.playSound(soundType: .explosion2)
    }
}
