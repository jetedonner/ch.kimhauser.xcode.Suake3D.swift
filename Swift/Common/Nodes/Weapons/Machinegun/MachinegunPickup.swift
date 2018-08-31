//
//  MachinegunPickup.swift
//  Suake3D
//
//  Created by dave on 25.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class MachinegunPickup:WeaponPickupBase{
    
    convenience init(_game: GameViewController){
        self.init()
        self.game = _game
    }
    
    required override init(){
        let scene:SCNScene = SCNScene(named: "game.scnassets/weapons/machinegun/m249.dae")!
        var daNewNode:SCNNode = SCNNode()
        
        var nodeArray3 = scene.rootNode.childNodes
        for childNode1 in nodeArray3 {
            var childNode2 = (scene.rootNode.childNode(withName: childNode1.name!, recursively: true))!
            daNewNode.addChildNode(childNode2)
        }
        
        super.init(node: daNewNode)
        
        // Init gun specific var
        self.rescale = 0.03
        self.initShots(/*shots: 10, */shotsPerPickup: 10, colorOnMap: SKColor.purple)
        
        self.scale.x = rescale
        self.scale.y = rescale
        self.scale.z = rescale
        
        let gNodeShape = SCNPhysicsShape(geometry: (self.geometry)!, options: [SCNPhysicsShape.Option.scale: SCNVector3(rescale, rescale, rescale)])
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: gNodeShape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = CollisionCategory.MachineGunCategory
        self.physicsBody?.contactTestBitMask = CollisionCategory.MachineGunCategory|CollisionCategory.SuakeCategory/*|CollisionCategory.SuakeOpCategory*/
        
        let animation = RotationAnim.getRotationAnim()
        self.addAnimation(animation, forKey: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
