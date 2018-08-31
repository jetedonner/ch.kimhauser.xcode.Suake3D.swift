//
//  Portal.swift
//  Suake3D
//
//  Created by dave on 01.08.18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation
import SceneKit

class Portal:BaseSuakeNodeExt {
    
    var grpId:Int = 0
    public var inPortal:Bool = true
    public var coord:SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    let txt:SCNNode = SCNNode()
    
    var lblIsHidden: Bool {
        set {
            txt.isHidden = newValue
        }
        get { return txt.isHidden }
    }
    
    convenience init(game:GameViewController, grpId:Int, inPortal:Bool, coord:SCNVector3) {
        var geo:SCNGeometry = SCNCone()
        var geo2:SCNGeometry = SCNCylinder(radius: 10, height: 30)
        var contactNode = SCNNode(geometry: geo2)
        self.init(node: SCNNode(geometry: geo), game: game)
        self.grpId = grpId
        contactNode.opacity = 0
        if(inPortal){
            addChildNode(contactNode)
        }
        self.inPortal = inPortal
        var portalSceneFile:String = "portalscene"
        if(!self.inPortal){
            portalSceneFile = "portalsceneOut"
        }
        
        let particleSystem = SCNParticleSystem(named: portalSceneFile, inDirectory: nil)
        addParticleSystem(particleSystem!)
        var inOut:String = "In: "
        if(!inPortal){
            inOut = "Out: "
        }
        let text:SCNText = SCNText(string: inOut +  grpId.description + " (x: " + Int(coord.x).description + "/ z: " + Int(coord.z).description + ")" , extrusionDepth: 2.5)
        
        txt.geometry = text
        txt.scale = SCNVector3(x: 0.2, y: 0.2, z: 0.2)
        txt.position.y += 30
        txt.addAnimation(RotationAnim.getRotationAnim(), forKey: nil)
        
        //Center pivot
        let (minVec, maxVec) = txt.boundingBox
        txt.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        //scnView.scene?.rootNode.addChildNode(textNode)
        addChildNode(txt)
        pos = coord
        if(!self.inPortal){
            position = SCNVector3(x: pos.x * game.suake.moveDist, y: 1, z: pos.z * game.suake.moveDist)
        }else{
            position = SCNVector3(x: pos.x * game.suake.moveDist, y: 1, z: pos.z * game.suake.moveDist + game.suake.moveDist)
        }
        
        if(inPortal){
            let particleShape = SCNPhysicsShape(geometry: (contactNode.geometry)!, options: nil)
            physicsBody = SCNPhysicsBody(type: .kinematic, shape: particleShape)
            physicsBody?.categoryBitMask = CollisionCategory.PortalInCategory
            physicsBody?.contactTestBitMask = CollisionCategory.PortalInCategory|CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory
        }
    }
}
