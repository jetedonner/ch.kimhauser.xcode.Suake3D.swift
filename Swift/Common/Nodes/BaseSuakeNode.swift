//
//  BaseSuakeNode.swift
//  iSuake3DNG
//
//  Created by dave on 11.01.18.
//  Copyright © 2018 dave. All rights reserved.
//

import Foundation
import SceneKit

class BaseSuakeNode : SCNNode {

    public var pos: SCNVector3 = SCNVector3(x:0, y:0, z:0)
    public var oldPos: SCNVector3 = SCNVector3(x:0, y:0, z:0)
    public var oldPosition: SCNVector3 = SCNVector3(x:0, y:0, z:0)
    public var bbMax:SCNVector3 = SCNVector3(x:0, y:0, z:0)
    public var bbMin:SCNVector3 = SCNVector3(x:0, y:0, z:0)
    public var size:SCNVector3 = SCNVector3(x:0, y:0, z:0)
    public var origNode:SCNNode!
    
    override init() {
        super.init()
    }
    
    /*public /*not inherited*/ init(geometry: SCNGeometry?){
        super.init(geometry: geometry)
    }*/
    
    init(node: SCNNode) {
        origNode = node
        bbMax = node.boundingBox.max
        bbMin = node.boundingBox.min
        size = SCNVector3(x: bbMax.x * 2, y:bbMax.y * 2, z: bbMax.z * 2)
        
        let nodeCopy:SCNNode = origNode.flattenedClone()
        super.init()
        
        self.geometry = nodeCopy.geometry
        self.geometry?.materials = (nodeCopy.geometry?.materials)!
        self.position = origNode.position
        
        self.pos = SCNVector3(x: 0, y: 0, z: 0)
        self.oldPos = SCNVector3(x: 0, y: 0, z: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
