//
//  GoodyNode.swift
//  iSuake3DNG
//
//  Created by dave on 10.01.18.
//  Copyright © 2018 dave. All rights reserved.
//

import Foundation
import SceneKit

class GoodyNode: BaseSuakeNode {
    
    public var isHit:Bool = false
    var game:GameViewController!
    var animations = [String: CAAnimation]()
    public var hitByBulletGrp:PelletGrp!
    //public var bbeMax:SCNVector3!
    //public var bbMin:SCNVector3!
    
    convenience init(_gameBoard: GameViewController){
        self.init()
        self.game = _gameBoard
    }
    
    required override init(){
        //let scene3 = SCNScene(named: "art.scnassets/obstacle.scn")!
        //var daNewNode:SCNNode// = SCNNode()
        //_________________002-anim
        //var scene = SCNScene(named: "art.scnassets/mouse11.scn")!
        var scene:SCNScene = SCNScene(named: "game.scnassets/goody/GoodyBASE2.scn")! // GoodyALEMBIC.scn")! //GoodyBASE.dae")! // mouse15.scn")!
        //var nodeArray = scene5.rootNode.childNodes
        //var daNewNode:SCNNode = scene5.rootNode.childNode(withName: "_________________002", recursively: true)!
        var daNewNode:SCNNode = SCNNode() //= scene.rootNode//.childNode(withName: "_Sphere002", recursively: true)!
        var nodeArray3 = scene.rootNode.childNodes
        for childNode1 in nodeArray3 {
            
            var childNode2 = (scene.rootNode.childNode(withName: childNode1.name!, recursively: true))!
            
            if(childNode1.name == "nurbsTorus1"){
                //childNode1.geometry?.firstMaterial?.emission.contents = NSColor.yellow
                let filter = CIFilter(name: "CIGaussianBlur")!
                filter.setDefaults()
                //filter.setValue(21, forKey: kCIInputRadiusKey)
                //let atmosphere=SCNSphere(radius: 21)
                let atmosphere:SCNTorus = SCNTorus(ringRadius: 21, pipeRadius: 0.5)
                atmosphere.firstMaterial?.diffuse.contents = NSColor.red
                //childNode2.geometry?.firstMaterial?.diffuse.contents = NSColor.red
                //let atmosphereNode:SCNTorus = SCNNode(geometry: childNode2.geometry)
                //let atmosphereNode = SCNNode(geometry: childNode2.geometry)
                let atmosphereNode = SCNNode(geometry: atmosphere)
                atmosphereNode.filters=[filter]
                //atmosphereNode.geometry.
                daNewNode.addChildNode(atmosphereNode)
            }/*else if(childNode1.name == "_Sphere002"){
                var nodeArray4 = childNode1.childNodes
                var daNewNode2:SCNNode = SCNNode()
                for childNode6 in nodeArray4 {
                    
                    var childNode7 = (scene.rootNode.childNode(withName: childNode6.name!, recursively: true))!
                    
                    if(childNode6.name == "_________________1"){
                        //childNode1.geometry?.firstMaterial?.emission.contents = NSColor.yellow
                        let filter = CIFilter(name: "CIGaussianBlur")!
                        filter.setDefaults()
                        filter.setValue(1, forKey: kCIInputRadiusKey)
                        //let atmosphere=SCNSphere(radius: 21)
                        childNode7.geometry?.firstMaterial?.diffuse.contents = NSColor.green
                        let atmosphereNode = SCNNode(geometry: childNode7.geometry)
                        atmosphereNode.filters=[filter]
                        daNewNode2.addChildNode(atmosphereNode)
                    }else{
                        daNewNode2.addChildNode(childNode7)
                    }
                }
                daNewNode.addChildNode(daNewNode2)
            }*/else{
                daNewNode.addChildNode(childNode2)
            }
            if(childNode2.animationKeys.count > 0){
                for i in (0..<childNode2.animationKeys.count) {
                    let key:String = childNode2.animationKeys[i]
                daNewNode.addAnimationPlayer(childNode2.animationPlayer(forKey: key)!, forKey: key)
                    daNewNode.animationPlayer(forKey: key)?.stop()
                }
            }
        }
        
        super.init(node: daNewNode)
        
        let mouseShape = SCNPhysicsShape(geometry: (geometry)!, options: nil /*[SCNPhysicsShape.Option.scale: SCNVector3(16, 16, 16)]*/)
        physicsBody = SCNPhysicsBody(type: .static, shape: mouseShape)
        physicsBody?.isAffectedByGravity = false
        physicsBody?.categoryBitMask = CollisionCategory.MouseCategory
        physicsBody?.contactTestBitMask = CollisionCategory.MouseCategory|CollisionCategory.SuakeCategory|CollisionCategory.RocketCategory|CollisionCategory.PelletCategory
        
        //let animation = CABasicAnimation(keyPath: "rotation")
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(scnVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(Double.pi)*2))
        animation.duration = 3.0
        animation.repeatCount = MAXFLOAT //repeat forever
        addAnimation(animation, forKey: "rotation")
        
        //loadAnimation(withKey: "rotate", daeNamed: "mouse5")
        //playAnimation(named: "rotate")
    }
    
    func placeOnBoard(pos:SCNVector3){
        self.pos = pos //SCNVector3(x: 0, y: 15, z: 1)
        self.oldPos = pos // SCNVector3(x: 0, y: 15, z: 1)
        self.position = SCNVector3(x: (self.pos.x * -100), y: 0 /*self.bbMax.y*/, z: self.pos.z * 100)
        game.gameView.scene?.rootNode.addChildNode(self)
    }
    
    func newGoodyPos(){
        self.pos.z -= 3.0
    }
    
    func posGoody(){
        self.position.x = (game.suake.moveDist * self.pos.x) //+ 50
        self.position.z = game.suake.moveDist * self.pos.z + (game.suake.moveDist / 2)
        self.position.z = game.suake.moveDist * self.pos.z + (game.suake.moveDist / 2)
        self.position.x = game.suake.moveDist * self.pos.x
        self.isHit = false
    }
    
    func getSceneSource(daeNamed: String) -> SCNSceneSource {
        let collada = Bundle.main.url(forResource: "art.scnassets/\(daeNamed)", withExtension: "dae")!
        return SCNSceneSource(url: collada, options: nil)!
    }
    
    func loadAnimation(withKey: String, daeNamed: String, fade: CGFloat = 0.3){
        let sceneSource = getSceneSource(daeNamed: daeNamed)
        let animation = sceneSource.entryWithIdentifier("_Sphere002-anim", withClass: CAAnimation.self)!
        
        // animation.speed = 1
        animation.fadeInDuration = fade
        animation.fadeOutDuration = fade
        // animation.beginTime = CFTimeInterval( fade!)
        animations[withKey] = animation
    }
    
    func playAnimation(named: String){ //also works for armature
        if let animation = animations[named] {
            addAnimation(animation, forKey: named)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
