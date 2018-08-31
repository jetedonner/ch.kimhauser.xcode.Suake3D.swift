//
//  MachinegunBulllet.swift
//  Suake3D iOS
//
//  Created by dave on 26.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

class MachinegunBullet:BulletBase{
    
    convenience init(_game: GameViewController){
        self.init()
        self.game = _game
        self.name = "MachinegunBulllet"
    }
    
    required override init(){
        let scene:SCNScene = SCNScene(named: "game.scnassets/weapons/machinegun/MachinegunBulllet.dae")!
        var daNewNode:SCNNode = SCNNode()
        
        var nodeArray3 = scene.rootNode.childNodes
        for childNode1 in nodeArray3 {
            var childNode2 = (scene.rootNode.childNode(withName: childNode1.name!, recursively: true))!
            daNewNode.addChildNode(childNode2)
        }
        
        super.init(node: daNewNode)
        // Init gun specific var
        self.name = "MachinegunBullet"
        self.rescale = 0.2
        self.damage = 25
        //self.initShots(shots: 10, shotsPerPickup: 10, colorOnMap: SKColor.purple)
        
        self.scale.x = rescale
        self.scale.y = rescale
        self.scale.z = rescale
        
        let gNodeShape = SCNPhysicsShape(geometry: (self.geometry)!, options: [SCNPhysicsShape.Option.scale: SCNVector3(rescale, rescale, rescale)])
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: gNodeShape)
        self.physicsBody?.isAffectedByGravity = true
        self.physicsBody?.categoryBitMask = CollisionCategory.MachineGunBulletCategory
        self.physicsBody?.contactTestBitMask = CollisionCategory.MachineGunBulletCategory|CollisionCategory.SuakeCategory|CollisionCategory.SuakeOpCategory|CollisionCategory.PortalInCategory/*|CollisionCategory.SuakeOpCategory*/
        applyForceToBullet(blt: self, vect: SCNVector3(x: 0, y: 0, z: shootingVelocity))
        //self.physicsBody?.applyForce(SCNVector3(x: 0, y: 0, z: 85), asImpulse: true)
    }
    
    func applyForceToBullet(blt:MachinegunBullet, vect:SCNVector3){
        blt.physicsBody?.velocity = vect
        blt.physicsBody?.applyForce(vect, asImpulse: true)
    }
    
    /*override func fireSpecificShot()->MachinegunBulllet{
        let bullet:MachinegunBulllet = MachinegunBulllet(_game: self.game)
        applyForceToBullet(blt: bullet, vect: SCNVector3(x: 0, y: 0, z: 85))
        return bullet
    }*/
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
