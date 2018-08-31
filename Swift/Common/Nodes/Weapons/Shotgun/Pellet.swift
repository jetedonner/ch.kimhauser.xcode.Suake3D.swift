//
//  Bullet.swift
//  ARViewer
//
//  Created by Faris Sbahi on 6/6/17.
//  Copyright © 2017 Faris Sbahi. All rights reserved.
//
//import UIKit
import SceneKit

// Spheres that are shot at the "ships"
class Pellet: BulletBase {
    
    public var bltGrp: PelletGrp!
    
    convenience init(_game: GameViewController){
        self.init()
        self.game = _game
        self.name = "PelletNode"
    }
    
    required override init(){
        super.init()
        self.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        self.damage = 9
        
        let sphere = SCNSphere(radius: 1)
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = true
        self.physicsBody?.categoryBitMask = CollisionCategory.PelletCategory
        self.physicsBody?.contactTestBitMask = CollisionCategory.PelletCategory|CollisionCategory.MouseCategory|CollisionCategory.SuakeOpCategory|CollisionCategory.RocketCategory|CollisionCategory.PortalInCategory
        
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.darkGray
        sphere.firstMaterial = material
        self.geometry?.materials  = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
