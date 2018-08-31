//
//  Railgun.swift
//  iSuake3DNG
//
//  Created by dave on 24.02.18.
//  Copyright © 2018 dave. All rights reserved.
//

import Foundation
import SceneKit

func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
    let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
    if length == 0 {
        return SCNVector3(0.0, 0.0, 0.0)
    }
    
    return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
}

extension SCNNode {
    func buildLineInTwoPointsWithRotation(from startPoint: SCNVector3,
                                          to endPoint: SCNVector3,
                                          radius: CGFloat,
                                          color: NSColor) -> SCNNode {
        let w = SCNVector3(x: endPoint.x-startPoint.x,
                           y: endPoint.y-startPoint.y,
                           z: endPoint.z-startPoint.z)
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))
        
        if l == 0.0 {
            // two points together.
            let sphere = SCNSphere(radius: radius)
            sphere.firstMaterial?.diffuse.contents = color
            self.geometry = sphere
            self.position = startPoint
            return self
            
        }
        
        let cyl = SCNCylinder(radius: radius, height: l)
        cyl.firstMaterial?.diffuse.contents = color
        
        self.geometry = cyl
        
        //original vector of cylinder above 0,0,0
        let ov = SCNVector3(0, l/2.0,0)
        //target vector, in new coordination
        let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                            (endPoint.z-startPoint.z)/2.0)
        
        // axis between two vector
        let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
        
        //normalized axis vector
        let av_normalized = normalizeVector(av)
        let q0 = CGFloat(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = CGFloat(av_normalized.x) // x' * sin(angle/2)
        let q2 = CGFloat(av_normalized.y) // y' * sin(angle/2)
        let q3 = CGFloat(av_normalized.z) // z' * sin(angle/2)
        
        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
        
        self.transform.m11 = r_m11
        self.transform.m12 = r_m12
        self.transform.m13 = r_m13
        self.transform.m14 = 0.0
        
        self.transform.m21 = r_m21
        self.transform.m22 = r_m22
        self.transform.m23 = r_m23
        self.transform.m24 = 0.0
        
        self.transform.m31 = r_m31
        self.transform.m32 = r_m32
        self.transform.m33 = r_m33
        self.transform.m34 = 0.0
        
        self.transform.m41 = (startPoint.x + endPoint.x) / 2.0
        self.transform.m42 = (startPoint.y + endPoint.y) / 2.0
        self.transform.m43 = (startPoint.z + endPoint.z) / 2.0
        self.transform.m44 = 1.0
        return self
    }
}

class Railgun : SCNNode, CAAnimationDelegate {
    
    var game:GameViewController!
    public var twoPointsNode2:SCNNode!
    let shotY:CGFloat = 16
    var anim:CAAnimationGroup!
    var fadeAnim:CABasicAnimation!
    
    init(_game:GameViewController) {
        super.init()
        self.game = _game
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addWPRailgun(){
        let daNewNode:BaseSuakeNode = BaseSuakeNode()
        let animation = RotationAnim.getRotationAnim()
        var scene5:SCNScene = SCNScene(named: "art.scnassets/raul.scn")!
        var nodeArray = scene5.rootNode.childNodes
        
        for childNode in nodeArray {
            daNewNode.addChildNode(childNode as SCNNode)
        }
        daNewNode.position = SCNVector3(x: -8 * game.suake.suakeHead.size.x, y: 8, z: game.suake.suakeHead.size.z * 2)
        daNewNode.addAnimation(animation, forKey: "spin around")
        let daNewNodeShape = SCNPhysicsShape(geometry: nodeArray[0].geometry!, options: [SCNPhysicsShape.Option.scale: SCNVector3(0.03, 0.03, 0.03)])
        daNewNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: daNewNodeShape)
        daNewNode.physicsBody?.isAffectedByGravity = false
        daNewNode.physicsBody?.categoryBitMask = CollisionCategory.RailGunCategory
        daNewNode.physicsBody?.contactTestBitMask = CollisionCategory.RailGunCategory|CollisionCategory.SuakeCategory
        
        game.gameView.scene?.rootNode.addChildNode(daNewNode)
    }
    
    func addRailgunShot(){
        let twoPointsNode1 = SCNNode()
        
        let startZ:CGFloat = game.suake.suakeHead.presentation.position.z
        let startX:CGFloat = game.suake.suakeHead.presentation.position.x
        
        twoPointsNode2 = twoPointsNode1.buildLineInTwoPointsWithRotation(
            from: SCNVector3(startX, shotY, startZ /*+ ((game..geometry?.boundingBox.max.z)! * 26)*/), to: SCNVector3(startX, shotY, startZ /*+ ((game.gNodeFP.geometry?.boundingBox.max.z)! * 26)*/ + 450), radius: 0.25, color: .cyan)
        
        twoPointsNode2.opacity = 1.0
        let railgunShotShape = SCNPhysicsShape(geometry: (twoPointsNode2.geometry)!, options: nil)
        twoPointsNode2.physicsBody = SCNPhysicsBody(type: .static, shape: railgunShotShape)
        twoPointsNode2.physicsBody?.categoryBitMask = CollisionCategory.RailShotCategory
        twoPointsNode2.physicsBody?.contactTestBitMask = CollisionCategory.RailShotCategory|CollisionCategory.SuakeOpCategory|CollisionCategory.SuakeCategory
        
        game.scene.rootNode.addChildNode(twoPointsNode2)
        updHelix()
        game.mediaManager.playSound(soundType: .railgun)
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
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
            
        }
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
        
        /*let startZ:CGFloat = game.gNodeFP.presentation.position.z + 90
        let startX:CGFloat = game.gNodeFP.presentation.position.x
        
        //twoPointsNode2 = twoPointsNode1.buildLineInTwoPointsWithRotation(
        //from: SCNVector3(startX, shotY, startZ + ((gNodeFP.geometry?.boundingBox.max.z)! * 26)), to: SCNVector3(startX, shotY, startZ + ((gNodeFP.geometry?.boundingBox.max.z)! * 26) + 450), radius: 0.25, color: .cyan)
        helix.position = SCNVector3(startX, 16, startZ + ((game.suake.suakeHead.geometry?.boundingBox.max.z)! * 2) + ((game.gNodeFP.geometry?.boundingBox.max.z)! * 26))
        
        //helix.geometry?.firstMaterial?.diffuse.contents = NSColor.cyan
        //helix.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        game.scene.rootNode.addChildNode(helix)*/
    }
    
    @objc func animationDidStop(_ anim2: CAAnimation, finished flag: Bool){
        /*game.drawn = true
        if(anim2.isEqual(fadeAnim) && flag){
            self.twoPointsNode2.removeFromParentNode()
        }*/
    }
}
