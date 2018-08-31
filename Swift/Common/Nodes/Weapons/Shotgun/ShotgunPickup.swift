//
//  ShotgunPickup.swift
//  Suake3D
//
//  Created by dave on 24.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class ShotgunPickup: WeaponPickupBase {
 
    convenience init(_game:GameViewController) {
        self.init()
        self.game = _game
    }
    
    required override init(){
        
        guard let url = Bundle.main.url(forResource: "game.scnassets/weapons/shotgun/Shotgun", withExtension: "obj") else {
            fatalError("Failed to find model file.")
        }
        
        let asset = MDLAsset(url:url)
        guard let object = asset.object(at: 0) as? MDLMesh else {
            fatalError("Failed to get mesh from asset.")
        }
        
        let daNewNode:SCNNode = SCNNode(mdlObject: object)
        
        super.init(node: daNewNode)
        
        // Init gun specific var
        self.rescale = 7.0
        self.initShots(/*shots: 5, */shotsPerPickup: 5, colorOnMap: SKColor.blue)
        
        self.scale.x = rescale
        self.scale.y = rescale
        self.scale.z = rescale
        
        let gNodeShape = SCNPhysicsShape(geometry: (self.geometry)!, options: [SCNPhysicsShape.Option.scale: SCNVector3(rescale, rescale, rescale)])
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: gNodeShape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = CollisionCategory.ShotgunCategory
        self.physicsBody?.contactTestBitMask = CollisionCategory.ShotgunCategory|CollisionCategory.SuakeCategory/*|CollisionCategory.SuakeOpCategory*/
        
        let animation = RotationAnim.getRotationAnim()
        self.addAnimation(animation, forKey: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
