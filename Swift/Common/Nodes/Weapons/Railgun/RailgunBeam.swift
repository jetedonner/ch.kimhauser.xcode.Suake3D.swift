//
//  MachinegunBulllet.swift
//  Suake3D iOS
//
//  Created by dave on 26.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

class RailgunBeam: BulletBase/*, CAAnimationDelegate*/{
    
    public var twoPointsNode2:SCNNode!
    let shotY:CGFloat = 8
    var anim:CAAnimationGroup!
    var fadeAnim:CABasicAnimation!
    
    convenience init(_game: GameViewController){
        self.init()
        self.game = _game
        self.name = "RailgunBeam"
    }
    
    required override init(){
        super.init()
        self.damage = 100
        /*let scene:SCNScene = SCNScene(named: "game.scnassets/weapons/machinegun/MachinegunBulllet.dae")!
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
        */
    }
    
    func addRailgunShot(){
        addRailgunShot(pos: game.suake.suakeHead.presentation.position, beam: true)
    }
    
    func addRailgunShot(pos:SCNVector3, beam:Bool){
        let twoPointsNode1 = SCNNode()
        
        let startZ:CGFloat = pos.z // game.suake.suakeHead.presentation.position.z
        let startX:CGFloat = pos.x // game.suake.suakeHead.presentation.position.x
        
        let fields = 450 / game.suake.moveDist
        
        if(beam){
            game.mediaManager.playSound(soundType: .telein)
            let rgbBeamed:RailgunBeam = RailgunBeam(_game: self.game)
            rgbBeamed.addRailgunShot(pos: game.allPortalGroups[0].portalOut.position, beam: false)
            game.gameView.scene?.rootNode.addChildNode(rgbBeamed)
            //addRailgunShot(pos: game.allPortalGroups[0].portalOut.position, beam: false)
        }
        
        twoPointsNode2 = twoPointsNode1.buildLineInTwoPointsWithRotation(
            from: SCNVector3(startX, shotY, startZ /*+ ((game..geometry?.boundingBox.max.z)! * 26)*/), to: SCNVector3(startX, shotY, startZ /*+ ((game.gNodeFP.geometry?.boundingBox.max.z)! * 26)*/ + 450), radius: 0.25, color: .cyan)
        
        twoPointsNode2.opacity = 1.0
        self.addChildNode(twoPointsNode2)
        let railgunShotShape = SCNPhysicsShape(geometry: (twoPointsNode2.geometry)!, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: railgunShotShape)
        self.physicsBody?.categoryBitMask = CollisionCategory.RailShotCategory
        self.physicsBody?.contactTestBitMask = CollisionCategory.RailShotCategory|CollisionCategory.SuakeOpCategory/*|CollisionCategory.SuakeCategory*/
        
        
        //game.scene.rootNode.addChildNode(twoPointsNode2)
        updHelix()
        //game.mediaManager.playSound(soundType: .railgun)
        
    
        let when = DispatchTime.now() + (game.moveDelay * 0.1)
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.helix.runAction(SCNAction.fadeOut(duration: 0.125))
            self.twoPointsNode2.runAction(SCNAction.fadeOut(duration: 0.4))
            let when2 = DispatchTime.now() + 0.41
            DispatchQueue.main.asyncAfter(deadline: when2) {
                self.removeFromParentNode()
            }
        }
        
        /*Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
            self.fadeAnim = CABasicAnimation()
            self.fadeAnim.keyPath = "opacity"
            self.fadeAnim.fromValue = 1.0
            self.fadeAnim.toValue = 0.0
            self.fadeAnim.duration = 0.5
            self.fadeAnim.fillMode = kCAFillModeForwards
            self.fadeAnim.isRemovedOnCompletion = false
            self.fadeAnim.delegate = self
            //anim.animations = [fadeAnim]
            //anim.duration = 0.5
            //helix.addAnimation(anim, forKey: "")
            //twoPointsNode2.addAnimation(anim, forKey: "")
            //fadeAnim.run(forKey: "opacity", object: helix, arguments: nil)
            self.fadeAnim.run(forKey: "opacity", object: self.twoPointsNode2, arguments: nil)
            self.fadeAnim.run(forKey: "opacity", object: self.helix, arguments: nil)
            
        }*/
    }
    
    var helix:SCNNode!
    //var scene:SCNScene!
    var hHeight:Float = 60.0
    //var hOp:CGFloat = 1.0
    func updHelix(){
        if(helix != nil){
            helix.removeFromParentNode()
        }
        let helixHelper:HelixVertexArray = HelixVertexArray(width: 6.0, height: hHeight, depth: 3.2, pitch: 1.95, quality: true)
        
        helix = helixHelper.getNode()
        helix.transform = SCNMatrix4MakeRotation(CGFloat(Double.pi) / 2, 0.5, 0, 0)
        
        let startZ:CGFloat = game.suake.suakeHead.presentation.position.z + 90
         let startX:CGFloat = game.suake.suakeHead.presentation.position.x
         
         //twoPointsNode2 = twoPointsNode1.buildLineInTwoPointsWithRotation(
         //from: SCNVector3(startX, shotY, startZ + ((gNodeFP.geometry?.boundingBox.max.z)! * 26)), to: SCNVector3(startX, shotY, startZ + ((gNodeFP.geometry?.boundingBox.max.z)! * 26) + 450), radius: 0.25, color: .cyan)
         helix.position = SCNVector3(startX, 16, startZ + ((game.suake.suakeHead.geometry?.boundingBox.max.z)! * 2) + ((game.suake.suakeHead.geometry?.boundingBox.max.z)! * 26))
         
         //helix.geometry?.firstMaterial?.diffuse.contents = NSColor.cyan
         //helix.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
         game.scene.rootNode.addChildNode(helix)
    }
    
    /*@objc func animationDidStop(_ anim2: CAAnimation, finished flag: Bool){
        var i = -1
        i /= -1
        //game.drawn = true
         /*if(anim2.isEqual(fadeAnim) && flag){
         self.twoPointsNode2.removeFromParentNode()
         }*/
    }*/
    
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
