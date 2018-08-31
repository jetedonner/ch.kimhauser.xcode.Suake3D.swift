//
//  DustNode.swift
//  iSuake3DNG
//
//  Created by dave on 02.03.18.
//  Copyright © 2018 dave. All rights reserved.
//

import Foundation
import SceneKit

class FireNode:SuakeNode{
    
    var game:GameViewController!
    var show:Bool = true
    //var inPortal:Bool = true
    
    public var particleFireSystem:SCNParticleSystem!
    
    
    init(game:GameViewController, show:Bool/*, inPortal:Bool*/){
        //var geo:SCNGeometry = SCNCone()
        super.init()
        self.game = game
        self.show = show
        self.isHidden = !show
        self.name = "FireNode"
        //scale = SCNVector3(x: 10, y: 10, z: 10)
        //self.inPortal = inPortal
        //if(self.inPortal){
        particleFireSystem = SCNParticleSystem(named: "fire2", inDirectory: nil)
        particleFireSystem?.colliderNodes = [game.suake.suakeHead]
            /*particleDustSystem?.handle(SCNParticleEvent.collision, forProperties:[SCNParticleSystem.ParticleProperty.contactPoint], handler: {
                (data: UnsafeMutablePointer<UnsafeMutableRawPointer>, dataStride: UnsafeMutablePointer<Int>, indicies: UnsafeMutablePointer<UInt32>, count:Int) in
                //code on detection collision goes here
                var i = -1
                i /= -1
                } )*/
        
        particleFireSystem?.handle(.collision, forProperties: [.contactPoint /*.angle, .rotationAxis, .contactNormal*/], handler: { data, dataStride, indices, count in
            var i = -1
            i /= -1
            game.showDbgMsg(dbgMsg: "Particle contact")
        })
        
        addParticleSystem(particleFireSystem!)
        pos = SCNVector3(x: -2, y: 0, z: 1)
        //position = SCNVector3(x: game.suake.suakeHead.size.x * pos.x, y: game.suake.suakeHead.size.y * pos.y, z: game.suake.suakeHead.size.z * pos.z)
        let sLen = game.suake.moveDist // (game.suake.suakeHead.size.z + game.suake.suakeTail.size.z) / 10
        position = SCNVector3(x: sLen * pos.x - (sLen / 2), y: 0, z: pos.z * sLen + sLen)
        
            
            /*let fireShape = SCNPhysicsShape(geometry: (particleDustSystem)!, options: nil)
            physicsBody = SCNPhysicsBody(type: .static, shape: fireShape)
            physicsBody?.categoryBitMask = CollisionCategory.FireCategory
            physicsBody?.contactTestBitMask = CollisionCategory.FireCategory|CollisionCategory.SuakeCategory*/
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

