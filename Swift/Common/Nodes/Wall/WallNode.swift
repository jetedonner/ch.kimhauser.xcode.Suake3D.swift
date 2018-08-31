//
//  Wall.swift
//  Suake3D
//
//  Created by dave on 11.04.18.
//  Copyright © 2018 DaVe Inc. All rights reserved.
//

import Foundation
import SceneKit

class WallNode : BaseSuakeNodeExt {
    
    var wall:SCNNode!
    var wallGrp:SCNNode = SCNNode()
    
    override init(node: SCNNode, game: GameViewController) {
        super.init(node: node, game: game)
    }
    public func addWallNode(x: CGFloat, z: CGFloat){
        // UPPER
        addWallNode(x: x, z: z, scale: SCNVector3(x: 1, y: 1, z: 1))
    }
    
    public func addWallNode(x: CGFloat, z: CGFloat, scale: SCNVector3){
        // UPPER
        wall = origNode.copy() as! SCNNode
        wall.name = "WallNode"
        wall.scale = scale
        wall.position.x = x
        wall.position.z = z
        wallGrp.addChildNode(wall)
        //game.gameView.scene?.rootNode.addChildNode(wall)
    }
    
    public func addCompleteWall(){
        wallGrp.name = "WallGroup"
        game.gameView.scene?.rootNode.addChildNode(wallGrp)
    }
    
    public func addWallNode(x: CGFloat, y: CGFloat, z: CGFloat, transform: SCNMatrix4){
        // UPPER
        addWallNode(x: x, y: y, z: z, scale: SCNVector3(x: 1, y: 1, z: 1), transform: transform)
    }
    
    public func addWallNode(x: CGFloat, y: CGFloat, z: CGFloat, scale: SCNVector3, transform: SCNMatrix4){
        // UPPER
        wall = origNode.copy() as! SCNNode
        wall.name = "WallNode"
        wall.transform = transform
        wall.scale = scale
        wall.position.x =  x
        wall.position.y =  y
        wall.position.z = z
        wallGrp.addChildNode(wall)
        //game.gameView.scene?.rootNode.addChildNode(wall)
    }
    
    public func addWallNode(x: CGFloat, y: CGFloat, z: CGFloat, rotation: SCNVector4){
        // UPPER
        addWallNode(x: x, y: y, z: z, scale: SCNVector3(x: 1, y: 1, z: 1), rotation: rotation)
    }
    
    public func addWallNode(x: CGFloat, y: CGFloat, z: CGFloat, scale: SCNVector3, rotation: SCNVector4){
        wall = origNode.copy() as! SCNNode
        wall.name = "WallNode"
        wall.rotation = rotation
        wall.scale = scale
        wall.position.x =  x
        wall.position.y =  y
        wall.position.z = z
        wallGrp.addChildNode(wall)
        //game.gameView.scene?.rootNode.addChildNode(wall)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required override init() {
        fatalError("init() has not been implemented")
    }
}
