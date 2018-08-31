//
//  MachinegunBulllet.swift
//  Suake3D iOS
//
//  Created by dave on 26.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

class RocketNode:BulletBase{
    
    let shotParticleNode = SCNNode()
    
    convenience init(_game: GameViewController){
        self.init()
        self.game = _game
        self.name = "RocketNode"
    }
    
    required override init(){
        guard let url2 = Bundle.main.url(forResource: "game.scnassets/weapons/rocketlauncher/REORCRocketlauncher/rocketlauncher_shell", withExtension: "obj") else {
            fatalError("Failed to find model file.")
        }
        
        let asset2 = MDLAsset(url:url2)
        guard let object2 = asset2.object(at: 0) as? MDLMesh else {
            fatalError("Failed to get mesh from asset.")
        }
        
        let daNewNode:SCNNode = SCNNode(mdlObject: object2)
        super.init()
        //super.init(node: daNewNode)
        
        // Init gun specific var
        self.name = "RocketNode"
        self.rescale = 23
        self.damage = 75
        
        self.scale.x = rescale
        self.scale.y = rescale
        self.scale.z = rescale
        
        let shotParticleSystem = SCNParticleSystem(named: "shotBurst", inDirectory: "game.scnassets/weapons/rocketlauncher/effects")
        
        shotParticleNode.addParticleSystem(shotParticleSystem!)
        shotParticleNode.position = self.position
        shotParticleNode.name = "shotParticle"
        
        daNewNode.name = "shotNode"
        self.addChildNode(shotParticleNode)
        self.addChildNode(daNewNode)
        
        self.position = pos
        
        let box = SCNBox(width: (daNewNode.geometry?.boundingBox.max.x)!, height: (daNewNode.geometry?.boundingBox.max.y)!, length: (daNewNode.geometry?.boundingBox.max.z)!, chamferRadius: 0)
        self.geometry = box
        
        let shape = SCNPhysicsShape(geometry: self.geometry!, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = true
        
        //var zVelocity:CGFloat = 0.0
    }
    
    /*func applyForceToBullet(blt:MachinegunBullet, vect:SCNVector3){
        blt.physicsBody?.velocity = vect
        blt.physicsBody?.applyForce(vect, asImpulse: true)
    }*/
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
