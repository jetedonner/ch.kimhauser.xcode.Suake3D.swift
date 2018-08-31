//
//  SuakeNode.swift
//  iSuake3DNG
//
//  Created by dave on 10.01.18.
//  Copyright © 2018 dave. All rights reserved.
//

import Foundation
import SceneKit

extension Array where Element:SuakeNode {
    
}

class SuakeNodeNG : BaseSuakeNode {
    
    override init(node: SCNNode) {
        
        super.init(node: node)
        
        //origNode = node
        bbMax = node.boundingBox.max
        bbMin = node.boundingBox.min
        size = SCNVector3(x: bbMax.x * 2, y:bbMax.y * 2, z: bbMax.z * 2)
        
        //let nodeCopy:SCNNode = origNode.clone()
        //self.geometry = node.flattenedClone().geometry
        //self.geometry?.materials = (node.flattenedClone().geometry?.materials)!
        //self.position = node.flattenedClone().position
        
        //self.pos = SCNVector3(x: 0, y: 0, z: 0)
        //self.oldPos = SCNVector3(x: 0, y: 0, z: 0)
    }
    
    /*public var animNode:SCNNode!
    public var animPlayer:String = ""
    public var nodePos:Int = 0
    public var dir:SuakeDir = .UP
    public var oldDir:SuakeDir = .UP
    public var beamed:Bool = true
    public var opponent:Bool = false
    
    public var morpherRef: SCNMorpher?
    public var targetName: String = ""
    public var attackAnimation:CAAnimation!
    
    func morphGrow(){
        morpherRef?.setWeight(1.0, forTargetNamed: targetName)
    }
    
    func animation()->SCNAnimation{
        //let player:SCNAnimationPlayer = animationPlayer()
        //return player.animation
        return animationPlayer().animation
    }
    
    func animationPlayer()->SCNAnimationPlayer{
        return animationPlayer(forKey: animPlayer)!
    }
    
    func playAnim(){
        isPaused = false
        animationPlayer().play()
    }
    
    func stopAnim(){
        isPaused = true
        animationPlayer().stop()
    }
    
    required override init() {
        super.init()
    }
    
    //  Converted to Swift 4 by Swiftify v4.1.6792 - https://objectivec2swift.com/
    func duplicate(_ node: SCNNode?, with material: SCNMaterial?) {
        let newNode = node?.clone() as? SCNNode
        newNode?.geometry = node?.geometry
        newNode?.geometry?.firstMaterial = material
    }
    
    //  Converted to Swift 4 by Swiftify v4.1.6792 - https://objectivec2swift.com/
    func duplicateSuakeNode(/*_ node: SCNNode?, with material: SCNMaterial?*/)->SuakeNode{
        let newNode = self.clone() as? SuakeNode
        newNode?.geometry = self.geometry
        newNode?.geometry?.firstMaterial = self.geometry?.firstMaterial
        newNode?.bbMax = self.boundingBox.max
        newNode?.bbMin = self.boundingBox.min
        newNode?.size = SCNVector3(x: self.bbMax.x * 2, y: self.bbMax.y * 2, z: self.bbMax.z * 2)
        
        //let nodeCopy:SCNNode = origNode.clone()
        //copy.geometry = self.geometry
        //copy.geometry?.materials = (self.geometry?.materials)!
        newNode?.position = self.position
        
        newNode?.pos = self.pos // SCNVector3(x: 0, y: 0, z: 0)
        newNode?.oldPos = self.oldPos //SCNVector3(x: 0, y: 0, z: 0)
        //for anim in self.anim
        newNode?.animPlayer = self.animPlayer
        newNode?.addAnimation(self.animation(), forKey: self.animPlayer)
        newNode?.addAnimationPlayer(self.animationPlayer(), forKey: self.animPlayer)
        return newNode!
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! SuakeNode
        //copy.origNode = self
        copy.bbMax = self.boundingBox.max
        copy.bbMin = self.boundingBox.min
        copy.size = SCNVector3(x: self.bbMax.x * 2, y: self.bbMax.y * 2, z: self.bbMax.z * 2)
        
        //let nodeCopy:SCNNode = origNode.clone()
        copy.geometry = self.geometry
        copy.geometry?.materials = (self.geometry?.materials)!
        copy.position = self.position
        
        copy.pos = self.pos // SCNVector3(x: 0, y: 0, z: 0)
        copy.oldPos = self.oldPos //SCNVector3(x: 0, y: 0, z: 0)
        //for anim in self.anim
        copy.animPlayer = self.animPlayer
        copy.addAnimation(self.animation(), forKey: self.animPlayer)
        copy.addAnimationPlayer(self.animationPlayer(), forKey: self.animPlayer)
        return copy
    }
    
    class func generate(node: SCNNode) -> SuakeNode {
        let copy = node.copy() as! SuakeNode
        
        copy.origNode = node
        copy.bbMax = node.boundingBox.max
        copy.bbMin = node.boundingBox.min
        copy.size = SCNVector3(x: copy.bbMax.x * 2, y: copy.bbMax.y * 2, z: copy.bbMax.z * 2)
        
        //let nodeCopy:SCNNode = origNode.clone()
        copy.geometry = node.flattenedClone().geometry
        copy.geometry?.materials = (node.flattenedClone().geometry?.materials)!
        copy.position = node.flattenedClone().position
        
        copy.pos = SCNVector3(x: 0, y: 0, z: 0)
        copy.oldPos = SCNVector3(x: 0, y: 0, z: 0)
        
        return copy
    }
    
    /*override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! SuakeNode
        //origNode = node
        //bbeMax = node.boundingBox.max
        //bbMin = node.boundingBox.min
        //size = SCNVector3(x: bbeMax.x * 2, y:bbeMax.y * 2, z: bbeMax.z * 2)
        
        //let nodeCopy:SCNNode = origNode.clone()
        //self.geometry = node.flattenedClone().geometry
        //self.geometry?.materials = (node.flattenedClone().geometry?.materials)!
        //self.position = node.flattenedClone().position
        
        //self.pos = SCNVector3(x: 0, y: 0, z: 0)
        //self.oldPos = SCNVector3(x: 0, y: 0, z: 0)
        return copy
    }*/
    
    convenience init(node: SCNNode, opponent:Bool) {
        self.init(node: node)
        self.opponent = opponent
    }
    
    /*override init(node: SCNNode) {
        super.init(node: node)
        self.opponent = false
    }*/
    
    /*func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init()
        return copy
    }*/
    
    convenience override init(node: SCNNode) {
        
        self.init()
        
        origNode = node
        bbMax = node.boundingBox.max
        bbMin = node.boundingBox.min
        size = SCNVector3(x: bbMax.x * 2, y:bbMax.y * 2, z: bbMax.z * 2)
        
        //let nodeCopy:SCNNode = origNode.clone()
        self.geometry = node.flattenedClone().geometry
        self.geometry?.materials = (node.flattenedClone().geometry?.materials)!
        self.position = node.flattenedClone().position
        
        self.pos = SCNVector3(x: 0, y: 0, z: 0)
        self.oldPos = SCNVector3(x: 0, y: 0, z: 0)
    }
    
    /*
     class Shape : NSObject, NSCopying { // <== Note NSCopying
     var color : String
     
     required override init() { // <== Need "required" because we need to call dynamicType() below
     color = "Red"
     }
     
     func copyWithZone(zone: NSZone) -> AnyObject { // <== NSCopying
     // *** Construct "one of my current class". This is why init() is a required initializer
     let theCopy = self.dynamicType()
     theCopy.color = self.color
     return theCopy
     }
     }
     */
    */
    /* Xcode required this */
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
