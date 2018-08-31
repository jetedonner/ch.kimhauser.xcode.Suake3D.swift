//
//  RocketlauncherPickup.swift
//  Suake3D
//
//  Created by dave on 25.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class RocketlauncherPickup:WeaponPickupBase{
    convenience init(_game: GameViewController){
        self.init()
        self.game = _game
    }
    
    required override init(){
        
        guard let url = Bundle.main.url(forResource: "game.scnassets/weapons/rocketlauncher/REORCRocketlauncher/rocketlauncher", withExtension: "obj") else {
            fatalError("Failed to find model file.")
        }
        
        let asset = MDLAsset(url:url)
        guard let object = asset.object(at: 0) as? MDLMesh else {
            fatalError("Failed to get mesh from asset.")
        }
        
        let daNewNode:SCNNode = SCNNode(mdlObject: object)
        
        super.init(node: daNewNode)
        
        // Init gun specific var
        self.rescale = 26.0
        self.initShots(/*shots: 3, */shotsPerPickup: 3, colorOnMap: SKColor.cyan)
        
        self.scale.x = rescale
        self.scale.y = rescale
        self.scale.z = rescale
        
        let gNodeShape = SCNPhysicsShape(geometry: (self.geometry)!, options: [SCNPhysicsShape.Option.scale: SCNVector3(rescale, rescale, rescale)])
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: gNodeShape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = CollisionCategory.RocketLauncherCategory
        self.physicsBody?.contactTestBitMask = CollisionCategory.RocketLauncherCategory|CollisionCategory.SuakeCategory/*|CollisionCategory.SuakeOpCategory*/
        
        let animation = RotationAnim.getRotationAnim()
        self.addAnimation(animation, forKey: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
