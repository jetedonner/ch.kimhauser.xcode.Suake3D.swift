//
//  DustNode.swift
//  iSuake3DNG
//
//  Created by dave on 02.03.18.
//  Copyright © 2018 dave. All rights reserved.
//

import Foundation
import SceneKit

class DustNode:SuakeNode{
    
    var game:GameViewController!
    //var inPortal:Bool = true
    
    init(game:GameViewController/*, inPortal:Bool*/){
        //var geo:SCNGeometry = SCNCone()
        super.init()
        self.game = game
        self.name = "DustNode"
        //self.inPortal = inPortal
        //if(self.inPortal){
            let particleDustSystem = SCNParticleSystem(named: "smoke", inDirectory: "art.scnassets")
            addParticleSystem(particleDustSystem!)
            pos = SCNVector3(x: -2, y: 1, z: 5)
            //position = SCNVector3(x: game.suake.suakeHead.size.x * pos.x, y: game.suake.suakeHead.size.y * pos.y, z: game.suake.suakeHead.size.z * pos.z)
            position = SCNVector3(x: -2, y: 1, z: 550)
            
            //let particleInShape = SCNPhysicsShape(geometry: (geometry)!, options: nil)
            //physicsBody = SCNPhysicsBody(type: .static, shape: particleInShape)
            //physicsBody?.categoryBitMask = CollisionCategory.PortalInCategory
            //physicsBody?.contactTestBitMask = CollisionCategory.PortalInCategory|CollisionCategory.SuakeCategory
            
        /*}else{
            let particleSystemOut = SCNParticleSystem(named: "portalsceneOut", inDirectory: "art.scnassets")
            addParticleSystem(particleSystemOut!)
            pos = SCNVector3(x: 3, y: 0, z: 2)
            // (game.suake.suakeHead.geometry?.boundingBox.max.x)! +
            position = SCNVector3(x: game.suake.suakeHead.size.x * pos.x, y: 0, z: game.suake.suakeHead.size.z * pos.z)
            
            //let particleOutShape = SCNPhysicsShape(geometry: (geometry)!, options: nil)
            //physicsBody = SCNPhysicsBody(type: .static, shape: particleOutShape)
            //physicsBody?.categoryBitMask = CollisionCategory.PortalOutCategory
            //physicsBody?.contactTestBitMask = CollisionCategory.PortalOutCategory|CollisionCategory.SuakeCategory
        }*/
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required override init() {
        fatalError("init() has not been implemented")
    }
}

