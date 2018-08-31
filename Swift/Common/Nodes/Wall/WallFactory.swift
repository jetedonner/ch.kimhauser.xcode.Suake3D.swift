//
//  WallFactory.swift
//  Suake3D
//
//  Created by dave on 11.04.18.
//  Copyright © 2018 DaVe Inc. All rights reserved.
//

import Foundation
import SceneKit

class WallFactory  {
    
    var game:GameViewController!
    public let wallBottom:CGFloat = 8.0
    public let wallFields:CGFloat = 264.0
    public let margin:CGFloat = 5.0
    
    init(game: GameViewController) {
        //self.init()
        self.game = game
    }
    
    func createWall(){
        
        let wallWidth:CGFloat = 30//suake.suakeHead.size.z //50.0
        let wallHalftWidth:CGFloat = wallWidth / 2

        let plainPlaneGeometry = SCNPlane(width: wallWidth, height: wallWidth)
        plainPlaneGeometry.firstMaterial?.diffuse.contents = NSImage.init(named: "wall1.jpg")
        plainPlaneGeometry.firstMaterial?.isDoubleSided = true
        let plainPlane1 = SCNNode(geometry: plainPlaneGeometry)
        plainPlane1.position = SCNVector3Make(0, wallBottom, 75)

        let left:CGFloat = CGFloat(wallFields * wallWidth / 2)
        let bot:CGFloat = -1 * CGFloat(wallFields * wallWidth / 2) - (wallWidth * 2) + margin
        
        let wallNode:WallNode = WallNode(node: plainPlane1.copy() as! SCNNode , game: game)
        
        for i in (0..<Int(wallFields + 2.0)){
            if(i > 0){
                // UPPER
                wallNode.addWallNode(x: (left * -1) + (CGFloat(i) * wallWidth) - wallWidth + margin, z: CGFloat((wallFields - 1) * wallWidth / 2) + margin)
            }else{
                // UPPER
                wallNode.addWallNode(x: (left * -1) + (CGFloat(i) * wallWidth) - (wallWidth * 0.66666666) + margin, z: CGFloat((wallFields - 1) * wallWidth / 2) + margin, scale: SCNVector3(x: 0.33333333, y: 1, z: 1))
            }
            if(i > 0){
                // LOWER
                wallNode.addWallNode(x: (left * -1) + (CGFloat(i) * wallWidth) - wallWidth + margin, y: wallBottom, z: (CGFloat(wallFields * wallWidth / 2) * -1) - wallHalftWidth - margin, transform: SCNMatrix4MakeRotation(CGFloat(Double.pi), 0, 1, 0))
            }else{
                // LOWER
                wallNode.addWallNode(x: (left * -1) + (CGFloat(i) * wallWidth) - (wallWidth * 0.66666666) + margin, y: wallBottom, z: (CGFloat(wallFields * wallWidth / 2) * -1) - wallHalftWidth - margin, scale: SCNVector3(x: 0.33333333, y: 1, z: 1), transform: SCNMatrix4MakeRotation(CGFloat(Double.pi), 0, 1, 0))
            }
            if(i > 1){
                // RIGHT
                wallNode.addWallNode(x: (left * -1) - wallHalftWidth - margin, y: wallBottom, z: bot + (CGFloat(i) * wallWidth), rotation: SCNVector4(x: CGFloat(0), y: CGFloat(-1), z: CGFloat(0), w: CGFloat(Double.pi / 2.0)))
            }else if(i == 1){
                // RIGHT
                wallNode.addWallNode(x: (left * -1) - wallHalftWidth - margin, y: wallBottom, z: bot + (CGFloat(i) * wallWidth) + (wallWidth * 0.33333333), scale: SCNVector3(x: 0.33333333, y: 1, z: 1), rotation: SCNVector4(x: CGFloat(0), y: CGFloat(-1), z: CGFloat(0), w: CGFloat(Double.pi / 2.0)))
            }
    
            if(i > 1){
                // LEFT
                wallNode.addWallNode(x: left + wallHalftWidth + margin, y: wallBottom, z: bot + (CGFloat(i) * wallWidth), rotation: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(Double.pi / 2.0)))
            }else if(i == 1){
                // LEFT
                wallNode.addWallNode(x: left + wallHalftWidth + margin, y: wallBottom, z: bot + (CGFloat(i) * wallWidth) + (wallWidth * 0.33333333), scale: SCNVector3(x: 0.33333333, y: 1, z: 1), rotation: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(Double.pi / 2.0)))
            }
        }
        wallNode.addCompleteWall()
    }
}
