//
//  RailgunPickup.swift
//  Suake3D
//
//  Created by dave on 24.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class RailgunPickup:WeaponPickupBase{
    
    convenience init(_game: GameViewController){
        self.init()
        self.game = _game
    }
    
    required override init(){
        let scene:SCNScene = SCNScene(named: "game.scnassets/weapons/railgun/Railgun5.dae")!
        var daNewNode:SCNNode = SCNNode()
        
        var nodeArray3 = scene.rootNode.childNodes
        for childNode1 in nodeArray3 {
            var childNode2 = (scene.rootNode.childNode(withName: childNode1.name!, recursively: true))!
            daNewNode.addChildNode(childNode2)
        }
        
        super.init(node: daNewNode)
        
        // Init gun specific var
        self.rescale = 0.02
        self.initShots(/*shots: 2, */shotsPerPickup: 2, colorOnMap: SKColor.green)
        
        self.scale.x = rescale
        self.scale.y = rescale
        self.scale.z = rescale
        
        let gNodeShape = SCNPhysicsShape(geometry: (self.geometry)!, options: [SCNPhysicsShape.Option.scale: SCNVector3(rescale, rescale, rescale)])
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: gNodeShape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = CollisionCategory.RailGunCategory
        self.physicsBody?.contactTestBitMask = CollisionCategory.RailGunCategory|CollisionCategory.SuakeCategory/*|CollisionCategory.SuakeOpCategory*/
        
        let animation = RotationAnim.getRotationAnim()
        self.addAnimation(animation, forKey: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
