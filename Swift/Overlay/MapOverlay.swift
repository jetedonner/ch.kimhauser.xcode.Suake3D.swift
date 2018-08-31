//
//  MapOverlay.swift
//  iSuake3DNG
//
//  Created by dave on 24.02.18.
//  Copyright © 2018 dave. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

class MapOverlay{
    
    var dbg:SKLabelNode!
    var dbgOpp:SKLabelNode!
    var map:SKShapeNode!
    var suake:SKShapeNode!
    var suakeOpp:SKShapeNode!
    var suakeHealth:SKShapeNode!
    var goody:SKShapeNode!
    
    var machinegun:SKShapeNode!
    var shotgun:SKShapeNode!
    var rocketLauncher:SKShapeNode!
    var railgun:SKShapeNode!
    
    var portalIn:SKShapeNode!
    var portalOut:SKShapeNode!
    
    let frameColor:SKColor = SKColor.lightGray
    
    let txtColor:SKColor = SKColor.white
    let fontName:String = String("Helvetica")
    let txtFontSize:CGFloat = 16.0
    
    var mapSize:CGFloat = 324.0
    var basePosSuake:CGFloat = 162 - 4 // 60
    let lineWidth:CGFloat = 4.0
    let alpha:CGFloat = 1.0 //0.65
    let corrX:CGFloat = -1.0
    let corrY:CGFloat = -1.0
    var mapPos:CGPoint!
    let dbgYOffset:CGFloat = 14.0
    
    var gameBoard:GameViewController!
    
    init(gameBoard:GameViewController) {
        self.gameBoard = gameBoard
        self.mapSize = CGFloat(gameBoard.wallFields * lineWidth)
    }
    
    var isHidden: Bool {
        get {
            return map.isHidden
        }
        set {
            map.isHidden = newValue
        }
    }
    
    func drawMap(){
        
        map = SKShapeNode()
        map.strokeColor = frameColor
        
        let mapPath:CGMutablePath = CGMutablePath()
        mapPos = CGPoint(x: (gameBoard.gameWindowSize.width / 2) - 20 - CGFloat(mapSize), y: ((gameBoard.gameWindowSize.height / 2) * -1) + lineWidth + 20)
        var mapPosMap:CGPoint = mapPos
        mapPosMap.y += corrY
        mapPosMap.x += corrX
        mapPath.addRect(CGRect(origin: mapPosMap, size: CGSize(width: mapSize + (2 * lineWidth), height: mapSize + (2 * lineWidth))))
        
        map.path = mapPath
        map.lineWidth = lineWidth
        map.alpha = alpha
        
        dbg = SKLabelNode(text: "10:05")
        dbg.text = Int(gameBoard.suake.suakeHead.pos.x).description + "/" + Int(gameBoard.suake.suakeHead.pos.z).description // "10:05"
        dbg.fontColor = txtColor
        dbg.fontSize = txtFontSize
        dbg.fontName = fontName
        var dbgPos:CGPoint = mapPosMap
        dbgPos.y += CGFloat(mapSize) + dbgYOffset // - dbg.frame.height
        dbgPos.x += /*10 +*/ (dbg.frame.width / 2)
        dbg.position = dbgPos //CGPoint(x: 5, y: 5)
        dbg.alpha = alpha
        
        dbgOpp = SKLabelNode(text: "10:05")
        dbgOpp.text = Int(gameBoard.suakeOpp.suakeHead.pos.x).description + "/" + Int(gameBoard.suakeOpp.suakeHead.pos.z).description // "10:05"
        dbgOpp.fontColor = SKColor.white
        dbgOpp.fontSize = txtFontSize
        dbgOpp.fontName = fontName
        var dbgPos2:CGPoint = mapPosMap
        dbgPos2.y += CGFloat(mapSize) + dbgYOffset // - dbg.frame.height
        dbgPos2.x += CGFloat(mapSize) - 10/*10 + (dbgOpp.frame.width / -2)*/
        dbgOpp.position = dbgPos2 //CGPoint(x: 5, y: 5)
        dbgOpp.alpha = alpha
        
        //Suake HEALTH
        suakeHealth = SKShapeNode()
        suakeHealth.strokeColor = NSColor.green
        let suakeHealthPath:CGMutablePath = CGMutablePath()
        let suakeHealthPos:CGPoint = CGPoint(x: (gameBoard.gameWindowSize.width / 2) - 40, y: ((gameBoard.gameWindowSize.height / 2)))
        
        suakeHealthPath.addRect(CGRect(origin: suakeHealthPos, size: CGSize(width: 10, height: 40)))
        suakeHealth.path = suakeHealthPath
        suakeHealth.lineWidth = lineWidth
        suakeHealth.alpha = alpha
        
        // SUAKE NODES (You and Opponent(s))
        suake = drawSuake(color: NSColor.cyan, arrSuakeNodes: gameBoard.suake.arrSuakeNodes)
        
        // Suake Opponent NODE
        suakeOpp = drawSuake(color: NSColor.yellow, arrSuakeNodes: gameBoard.suakeOpp.arrSuakeNodes)
        
        // GOODY
        goody = getSKShapeNode(color:NSColor.blue, pos:gameBoard.goodyNode.pos)
        
        // WEAPONS
        machinegun = getSKShapeNode4WP(wp: gameBoard.machinegunWP)
        shotgun = getSKShapeNode4WP(wp: gameBoard.shotgunWP)
        rocketLauncher = getSKShapeNode4WP(wp: gameBoard.rocketlauncherWP)
        railgun = getSKShapeNode4WP(wp: gameBoard.railgunWP)
        
        // PORTALS (IN & OUT)
        //portalIn = getSKShapeNode(color:NSColor.green, pos:gameBoard.portal1.portalIn.pos)
        //portalOut = getSKShapeNode(color:NSColor.yellow, pos:gameBoard.portal1.portalOut.pos)
    }
    
    func drawSuake(color:NSColor, arrSuakeNodes:[SuakeNode])->SKShapeNode{
        var suake:SKShapeNode = SKShapeNode()
        suake.strokeColor = color
        var suakePath:CGMutablePath = CGMutablePath()
        for i in (0..<arrSuakeNodes.count){
            suakePath = drawLine(path: suakePath, from: CGPoint(x: mapPos.x + basePosSuake - (arrSuakeNodes[i].pos.x * lineWidth) - lineWidth, y: mapPos.y + basePosSuake + (arrSuakeNodes[i].pos.z * lineWidth) - lineWidth), to: CGPoint(x: mapPos.x + basePosSuake - (arrSuakeNodes[i].pos.x * lineWidth) - lineWidth, y: mapPos.y + basePosSuake + (arrSuakeNodes[i].pos.z * lineWidth)))
        }
        suake.path = suakePath
        suake.lineWidth = lineWidth
        suake.alpha = alpha
        return suake
    }
    
    func getSKShapeNode4WP(wp:WeaponPickupBase)->SKShapeNode{
        return getSKShapeNode(color: wp.colorOnMap, pos:wp.pos)
    }
    
    func getSKShapeNode(color:NSColor, pos:SCNVector3)->SKShapeNode{
        var nodeRet = SKShapeNode()
        nodeRet.strokeColor = color
        nodeRet.path = drawLine(path: CGMutablePath(), from:  CGPoint(x: mapPos.x + basePosSuake - (pos.x * lineWidth) - lineWidth, y: mapPos.y + basePosSuake + (pos.z * lineWidth) - lineWidth), to: CGPoint(x: mapPos.x + basePosSuake - (pos.x * lineWidth) - lineWidth, y: mapPos.y + basePosSuake + (pos.z * lineWidth)))
        nodeRet.lineWidth = lineWidth
        nodeRet.alpha = alpha
        return nodeRet
    }
    
    func drawLine(path:CGMutablePath, from:CGPoint, to:CGPoint)->CGMutablePath{
        path.move(to: from)
        path.addLine(to: to)
        return path
    }
    
    func getMap() -> SKShapeNode{
        drawMap()
        
        map.addChild(suakeHealth)
        map.addChild(goody)
        map.addChild(machinegun)
        map.addChild(shotgun)
        map.addChild(rocketLauncher)
        map.addChild(railgun)
        
        //map.addChild(portalIn)
        //map.addChild(portalOut)
        map.addChild(suake)
        map.addChild(suakeOpp)
        map.addChild(dbg)
        map.addChild(dbgOpp)
        return map
    }
}
